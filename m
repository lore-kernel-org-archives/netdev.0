From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Sun, 13 Nov 2016 15:23:38 +0100
Message-ID: <5828776A.1010104@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="hpsVurOuKbeg3J1T6mBC2GeC9sDO0c6ig"
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski
 <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-5330-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hpsVurOuKbeg3J1T6mBC2GeC9sDO0c6ig
Content-Type: multipart/mixed; boundary="FnL08gngGMavEQjuGawjk41AiTbXK9r4u";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski
 <luto@amacapital.net>, Daniel Borkmann <daniel@iogearbox.net>,
 Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
 "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <5828776A.1010104@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
References: <20161026065654.19166-1-mic@digikod.net>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>

--FnL08gngGMavEQjuGawjk41AiTbXK9r4u
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,

After the BoF at LPC last week, we came to a multi-step roadmap to
upstream Landlock.

A first patch series containing the basic properties needed for a
"minimum viable product", which means being able to test it, without
full features. The idea is to set in place the main components which
include the LSM part (some hooks with the manager logic) and the new
eBPF type. To have a minimum amount of code, the first userland entry
point will be the seccomp syscall. This doesn't imply non-upstream
patches and should be more simple. For the sake of simplicity and to
ease the review, this first series will only be dedicated to privileged
processes (i.e. with CAP_SYS_ADMIN). We may want to only allow one level
of rules at first, instead of dealing with more complex rule inheritance
(like seccomp-bpf can do).

The second series will focus on the cgroup manager. It will follow the
same rules of inheritance as the Daniel Mack's patches does.

The third series will try to bring a BPF map of handles for Landlock and
the dedicated BPF helpers.

Finally, the fourth series will bring back the unprivileged mode (with
no_new_privs), at least for process hierarchies (via seccomp). This also
imply to handle multi-level of rules.

Right now, an important point of attention is the userland ABI. We don't
want LSM hooks to be exposed "as is" to userland. This may have some
future implications if their semantic and/or enforcement point(s)
change. In the next series, I will propose a new abstraction over the
currently used LSM hooks. I'll also propose a new way to deal with
resource accountability. Finally, I plan to create a minimal (kernel)
developer documentation and a test suite.

Regards,
 Micka=C3=ABl


On 26/10/2016 08:56, Micka=C3=ABl Sala=C3=BCn wrote:
> Hi,
>=20
> This fourth RFC brings some improvements over the previous one [1]. An =
important
> new point is the abstraction from the raw types of LSM hook arguments. =
It is
> now possible to call a Landlock function the same way for LSM hooks wit=
h
> different internal argument types. Some parts of the code are revamped =
with RCU
> to properly deal with concurrency. From a userland point of view, the o=
nly
> remaining link with seccomp-bpf is the ability to use the seccomp(2) sy=
scall to
> load and enforce a Landlock rule. Seccomp filters cannot trigger Landlo=
ck rules
> anymore. For now, it is no more possible for an unprivileged user to en=
force a
> Landlock rule on a cgroup through delegation.
>=20
> As suggested, I plan to write documentation for userland and kernel dev=
elopers
> with some kind of guiding principles. A remaining question is how to en=
force
> limitations for the rule creation?
>=20
>=20
> # Landlock LSM
>=20
> The goal of this new stackable Linux Security Module (LSM) called Landl=
ock is
> to allow any process, including unprivileged ones, to create powerful s=
ecurity
> sandboxes comparable to the Seatbelt/XNU Sandbox or the OpenBSD Pledge.=
 This
> kind of sandbox is expected to help mitigate the security impact of bug=
s or
> unexpected/malicious behaviors in userland applications.
>=20
> eBPF programs are used to create a security rule. They are very limited=
 (i.e.
> can only call a whitelist of functions) and cannot do a denial of servi=
ce (i.e.
> no loop). A new dedicated eBPF map allows to collect and compare Landlo=
ck
> handles with system resources (e.g. files or network connections).
>=20
> The approach taken is to add the minimum amount of code while still all=
owing
> the userland to create quite complex access rules. A dedicated security=
 policy
> language as the one used by SELinux, AppArmor and other major LSMs invo=
lves a
> lot of code and is usually dedicated to a trusted user (i.e. root).
>=20
>=20
> # eBPF
>=20
> To get an expressive language while still being safe and small, Landloc=
k is
> based on eBPF. Landlock should be usable by untrusted processes and mus=
t then
> expose a minimal attack surface. The eBPF bytecode is minimal while pow=
erful,
> widely used and designed to be used by not so trusted application. Reus=
ing this
> code allows to not reproduce the same mistakes and minimize new code  w=
hile
> still taking a generic approach. Only a few additional features are add=
ed like
> a new kind of arraymap and some dedicated eBPF functions.
>=20
> An eBPF program has access to an eBPF context which contains the LSM ho=
ok
> arguments (as does seccomp-bpf with syscall arguments). They can be use=
d
> directly or passed to helper functions according to their types. It is =
then
> possible to do complex access checks without race conditions nor incons=
istent
> evaluation (i.e. incorrect mirroring of the OS code and state [2]).
>=20
> There is one eBPF program subtype per LSM hook. This allows to statical=
ly check
> which context access is performed by an eBPF program. This is needed to=
 deny
> kernel address leak and ensure the right use of LSM hook arguments with=
 eBPF
> functions. Moreover, this safe pointer handling removes the need for ru=
ntime
> check or abstract data, which improves performances. Any user can add m=
ultiple
> Landlock eBPF programs per LSM hook. They are stacked and evaluated one=
 after
> the other (cf. seccomp-bpf).
>=20
>=20
> # LSM hooks
>=20
> Unlike syscalls, LSM hooks are security checkpoints and are not archite=
cture
> dependent. They are designed to match a security need associated with a=

> security policy (e.g. access to a file). Exposing parts of some LSM hoo=
ks
> instead of using the syscall API for sandboxing should help to avoid bu=
gs and
> hacks as encountered by the first RFC. Instead of redoing the work of t=
he LSM
> hooks through syscalls, we should use and expose them as does policies =
of
> access control LSM.
>=20
> Only a subset of the hooks are meaningful for an unprivileged sandbox m=
echanism
> (e.g. file system or network access control). Landlock uses an abstract=
ion of
> raw LSM hooks, which allow to deal with possible future API changes of =
the LSM
> hook API. Moreover, thanks to the ePBF program typing (per LSM hook) us=
ed by
> Landlock, it should not be hard to make such evolutions backward compat=
ible.
>=20
>=20
> # Use case scenario
>=20
> First, a process needs to create a new dedicated eBPF map containing ha=
ndles.
> This handles are references to system resources (e.g. file or directory=
) and
> grouped in one or multiple maps to be efficiently managed and checked i=
n
> batches. This kind of map can be passed to Landlock eBPF functions to c=
ompare,
> for example, with a file access request. The handles are only accessibl=
e from
> the eBPF programs created by the same thread.
>=20
> The loaded Landlock eBPF programs can be triggered by a seccomp filter
> returning RET_LANDLOCK. In addition, a cookie (16-bit value) can be pas=
sed from
> a seccomp filter to eBPF programs. This allow flexible security policie=
s
> between seccomp and Landlock.
>=20
> Another way to enforce a Landlock security policy is to attach Landlock=

> programs to a dedicated cgroup. All the processes in this cgroup will t=
hen be
> subject to this policy. For unprivileged processes, this can be done th=
anks to
> cgroup delegation.
>=20
> A triggered Landlock eBPF program can allow or deny an access, accordin=
g to
> its subtype (i.e. LSM hook), thanks to errno return values.
>=20
>=20
> # Sandbox example with process hierarchy sandboxing (seccomp)
>=20
>   $ ls /home
>   user1
>   $ LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>       ./samples/landlock/sandbox /bin/sh -i
>   Launching a new sandboxed process.
>   $ ls /home
>   ls: cannot access '/home': No such file or directory
>=20
>=20
> # Sandbox example with conditional access control depending on a cgroup=

>=20
>   $ mkdir /sys/fs/cgroup/sandboxed
>   $ ls /home
>   user1
>   $ LANDLOCK_CGROUPS=3D'/sys/fs/cgroup/sandboxed' \
>       LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>       ./samples/landlock/sandbox
>   Ready to sandbox with cgroups.
>   $ ls /home
>   user1
>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>   $ ls /home
>   ls: cannot access '/home': No such file or directory
>=20
>=20
> # Current limitations and possible improvements
>=20
> For now, eBPF programs can only return an errno code. It may be interes=
ting to
> be able to do other actions like seccomp-bpf does (e.g. kill process). =
Such
> features can easily be implemented but the main advantage of the curren=
t
> approach is to be able to only execute eBPF programs until one returns =
an errno
> code instead of executing all programs like seccomp-bpf does.
>=20
> It is quite easy to add new eBPF functions to extend Landlock. The main=
 concern
> should be about the possibility to leak information from current proces=
s to
> another one (e.g. through maps) to not reproduce the same security sens=
itive
> behavior as ptrace.
>=20
> This design does not seem too intrusive but is flexible enough to allow=
 a
> powerful sandbox mechanism accessible by any process on Linux. The use =
of
> seccomp and Landlock is more suitable with the help of a userland libra=
ry (e.g.
> libseccomp) that could help to specify a high-level language to express=
 a
> security policy instead of raw eBPF programs. Moreover, thanks to LLVM,=
 it is
> possible to express an eBPF program with a subset of C.
>=20
>=20
> # FAQ
>=20
> ## Why does seccomp-bpf is not enough?
>=20
> A seccomp filter can access to raw syscall arguments which means that i=
t is not
> possible to filter according to pointed such as a file path. As the fir=
st
> version of this patch series demonstrated, filtering at the syscall lev=
el is
> complicated (e.g. need to take care of race conditions). This is mainly=
 because
> the access control checkpoints of the kernel are not at this high-level=
 but
> more underneath, at LSM hooks level. The LSM hooks are designed to hand=
le this
> kind of checks. This series use this approach to leverage the ability o=
f
> unprivileged users to limit themselves.
>=20
> Cf. "What it isn't?" in Documentation/prctl/seccomp_filter.txt
>=20
>=20
> ## Why using the seccomp(2) syscall?
>=20
> Landlock use the same semantic as seccomp to apply access rule restrict=
ions. It
> add a new layer of security for the current process which is inherited =
by its
> childs. It makes sense to use an unique access-restricting syscall (tha=
t should
> be allowed by seccomp-bpf rules) which can only drop privileges. Moreov=
er, a
> Landlock eBPF program could come from outside a process (e.g. passed th=
rough a
> UNIX socket). It is then useful to differentiate the creation/load of L=
andlock
> eBPF programs via bpf(2), from rule enforcing via seccomp(2).
>=20
>=20
> ## Why using cgroups?
>=20
> cgroups are designed to handle groups of processes. One use case is to =
manage
> containers. Sandboxing based on process hierarchy (seccomp) is design t=
o handle
> immutable security policies, which is a good security property but does=
 not
> match all use cases. A user can attach Landlock rules to a cgroup. Doin=
g so,
> all the processes in that cgroup will be subject to the security policy=
=2E
> However, if the user is allowed to manage this cgroup, it could dynamic=
ally
> move this group of processes to a cgroup with another security policy (=
or
> none). Landlock rules can be applied either on a process hierarchy (e.g=
=2E
> application with built-in sandboxing) or a group of processes (e.g. con=
tainer
> sandboxing). Both approaches can be combined for the same process.
>=20
>=20
> ## Does Landlock can limit network access or other resources?
>=20
> Limiting network access is obviously in the scope of Landlock but it is=
 not yet
> implemented. The main goal now is to get feedback about the whole conce=
pt, the
> API and the file access control part. More access control types could b=
e
> implemented in the future.
>=20
> Sargun Dhillon sent a RFC (Checmate) [4] to deal with network manipulat=
ion.
> This could be implemented on top of the Landlock framework.
>=20
>=20
> ## Why a new LSM? Are SELinux, AppArmor, Smack or Tomoyo not good enoug=
h?
>=20
> The current access control LSMs are fine for their purpose which is to =
give the
> *root* the ability to enforce a security policy for the *system*. What =
is
> missing is a way to enforce a security policy for any applications by i=
ts
> developer and *unprivileged user* as seccomp can do for raw syscall fil=
tering.
> Moreover, Landlock handles stacked hook programs from different users. =
It must
> then ensure there is no possible malicious interactions between these p=
rograms.
>=20
> Differences with other (access control) LSMs:
> * not only dedicated to administrators (i.e. no_new_priv);
> * limited kernel attack surface (e.g. policy parsing);
> * helpers to compare complex objects (path/FD), no access to internal k=
ernel
>   data (do not leak addresses);
> * constrained policy rules/programs (no DoS: deterministic execution ti=
me);
> * do not leak more information than the loader process can legitimately=
 have
>   access to (minimize metadata inference): must compare from an already=
 allowed
>   file (through a handle).
>=20
>=20
> ## Why not use a policy language like used by SElinux or AppArmor?
>=20
> This kind of LSMs are dedicated to administrators. They already manage =
the
> system and are not a threat to the system security. However, seccomp, a=
nd
> Landlock too, should be available to anyone, which potentially include
> untrusted users and processes. To reduce the attack surface, Landlock s=
hould
> expose the minimum amount of code, hence minimal complexity. Moreover, =
another
> threat is to make accessible to a malicious code a new way to gain more=

> information. For example, Landlock features should not allow a program =
to get
> the file owner if the directory containing this file is not readable. T=
his data
> could then be exfiltrated thanks to the access result. Thus, we should =
limit
> the expressiveness of the available checks. The current approach is to =
do the
> checks in such a way that only a comparison with an already accessed re=
source
> (e.g. file descriptor) is possible. This allow to have a reference to c=
ompare
> with, without exposing much information.
>=20
>=20
> ## As a developer, why do I need this feature?
>=20
> Landlock's goal is to help userland to limit its attack surface.
> Security-conscious developers would like to protect users from a securi=
ty bug
> in their applications and the third-party dependencies they are using. =
Such a
> bug can compromise all the user data and help an attacker to perform a
> privilege escalation. Using an *unprivileged sandbox* feature such as L=
andlock
> empowers the developer with the ability to properly compartmentalize it=
s
> software and limit the impact of vulnerabilities.
>=20
>=20
> ## As a user, why do I need a this feature?
>=20
> Any user can already use seccomp-bpf to whitelist a set of syscalls to
> reduce the kernel attack surface for a predefined set of processes. How=
ever an
> unprivileged user can't create a security policy like the root user can=
 thanks to
> SELinux and other access control LSMs. Landlock allows any unprivileged=
 user to
> protect their data from being accessed by any process they run but only=
 an
> identified subset. User tools can be created to help create such a high=
-level
> access control policy. This policy may not be powerful enough to expres=
s the
> same policies as the current access control LSMs, because of the threat=
 an
> unprivileged user can be to the system, but it should be enough for mos=
t
> use-cases (e.g. blacklist or whitelist a set of file hierarchies).
>=20
>=20
> # Changes since RFC v3
>=20
> * use abstract LSM hook arguments with custom types (e.g. *_LANDLOCK_AR=
G_FS for
>   struct file, struct inode and struct path)
> * add more LSM hooks to support full file system access control
> * improve the sandbox example
> * fix races and RCU issues:
>   * eBPF program execution and eBPF helpers
>   * revamp the arraymap of handles to cleanly deal with update/delete
> * eBPF program subtype for Landlock:
>   * remove the "origin" field
>   * add an "option" field
> * rebase onto Daniel Mack's patches v7 [3]
> * remove merged commit 1955351da41c ("bpf: Set register type according =
to
>   is_valid_access()")
> * fix spelling mistakes
> * cleanup some type and variable names
> * split patches
> * for now, remove cgroup delegation handling for unprivileged user
> * remove extra access check for cgroup_get_from_fd()
> * remove unused example code dealing with skb
> * remove seccomp-bpf link:
>   * no more seccomp cookie
>   * for now, it is no more possible to check the current syscall proper=
ties
>=20
>=20
> # Changes since RFC v2
>=20
> * revamp cgroup handling:
>   * use Daniel Mack's patches "Add eBPF hooks for cgroups" v5
>   * remove bpf_landlock_cmp_cgroup_beneath()
>   * make BPF_PROG_ATTACH usable with delegated cgroups
>   * add a new CGRP_NO_NEW_PRIVS flag for safe cgroups
>   * handle Landlock sandboxing for cgroups hierarchy
>   * allow unprivileged processes to attach Landlock eBPF program to cgr=
oups
> * add subtype to eBPF programs:
>   * replace Landlock hook identification by custom eBPF program types w=
ith a
>     dedicated subtype field
>   * manage fine-grained privileged Landlock programs
>   * register Landlock programs for dedicated trigger origins (e.g. sysc=
all,
>     return from seccomp filter and/or interruption)
> * performance and memory optimizations: use an array to access Landlock=
 hooks
>   directly but do not duplicated it for each thread (seccomp-based)
> * allow running Landlock programs without seccomp filter
> * fix seccomp-related issues
> * remove extra errno bounding check for Landlock programs
> * add some examples for optional eBPF functions or context access (netw=
ork
>   related) according to security checks to allow more features for priv=
ileged
>   programs (e.g. Checmate)
>=20
>=20
> # Changes since RFC v1
>=20
> * focus on the LSM hooks, not the syscalls:
>   * much more simple implementation
>   * does not need audit cache tricks to avoid race conditions
>   * more simple to use and more generic because using the LSM hook abst=
raction
>     directly
>   * more efficient because only checking in LSM hooks
>   * architecture agnostic
> * switch from cBPF to eBPF:
>   * new eBPF program types dedicated to Landlock
>   * custom functions used by the eBPF program
>   * gain some new features (e.g. 10 registers, can load values of diffe=
rent
> 	size, LLVM translator) but only a few functions allowed and a dedicate=
d map
>     type
>   * new context: LSM hook ID, cookie and LSM hook arguments
>   * need to set the sysctl kernel.unprivileged_bpf_disable to 0 (defaul=
t value)
>     to be able to load hook filters as unprivileged users
> * smaller and simpler:
>   * no more checker groups but dedicated arraymap of handles
>   * simpler userland structs thanks to eBPF functions
> * distinctive name: Landlock
>=20
>=20
> This series can be applied on top of Daniel Mack's patches for BPF_PROG=
_ATTACH
> v7 [3] on Linux v4.9-rc2. This can be tested with CONFIG_SECURITY_LANDL=
OCK,
> CONFIG_SECCOMP_FILTER and CONFIG_CGROUP_BPF. I would really appreciate
> constructive comments on the usability, architecture, code and userland=
 API of
> Landlock LSM.
>=20
> [1] https://lkml.kernel.org/r/20160914072415.26021-1-mic@digikod.net
> [2] https://crypto.stanford.edu/cs155/papers/traps.pdf
> [3] https://lkml.kernel.org/r/1477390454-12553-1-git-send-email-daniel@=
zonque.org
> [4] https://lkml.kernel.org/r/20160829114542.GA20836@ircssh.c.rugged-ni=
mbus-611.internal
>=20
> Regards,
>=20
> Micka=C3=ABl Sala=C3=BCn (18):
>   landlock: Add Kconfig
>   bpf: Move u64_to_ptr() to BPF headers and inline it
>   bpf,landlock: Add a new arraymap type to deal with (Landlock) handles=

>   bpf,landlock: Add eBPF program subtype and is_valid_subtype() verifie=
r
>   bpf,landlock: Define an eBPF program type for Landlock
>   fs: Constify path_is_under()'s arguments
>   landlock: Add LSM hooks
>   landlock: Handle file comparisons
>   landlock: Add manager functions
>   seccomp: Split put_seccomp_filter() with put_seccomp()
>   seccomp,landlock: Handle Landlock hooks per process hierarchy
>   bpf: Cosmetic change for bpf_prog_attach()
>   bpf/cgroup: Replace struct bpf_prog with struct bpf_object
>   bpf/cgroup: Make cgroup_bpf_update() return an error code
>   bpf/cgroup: Move capability check
>   bpf/cgroup,landlock: Handle Landlock hooks per cgroup
>   landlock: Add update and debug access flags
>   samples/landlock: Add sandbox example
>=20
>  fs/namespace.c                 |   2 +-
>  include/linux/bpf-cgroup.h     |  19 +-
>  include/linux/bpf.h            |  44 +++-
>  include/linux/cgroup-defs.h    |   2 +
>  include/linux/filter.h         |   1 +
>  include/linux/fs.h             |   2 +-
>  include/linux/landlock.h       |  95 +++++++++
>  include/linux/lsm_hooks.h      |   5 +
>  include/linux/seccomp.h        |  12 +-
>  include/uapi/linux/bpf.h       | 105 ++++++++++
>  include/uapi/linux/seccomp.h   |   1 +
>  kernel/bpf/arraymap.c          | 270 +++++++++++++++++++++++++
>  kernel/bpf/cgroup.c            | 139 ++++++++++---
>  kernel/bpf/syscall.c           |  71 ++++---
>  kernel/bpf/verifier.c          |  35 +++-
>  kernel/cgroup.c                |   6 +-
>  kernel/fork.c                  |  15 +-
>  kernel/seccomp.c               |  26 ++-
>  kernel/trace/bpf_trace.c       |  12 +-
>  net/core/filter.c              |  26 ++-
>  samples/Makefile               |   2 +-
>  samples/bpf/bpf_helpers.h      |   5 +
>  samples/landlock/.gitignore    |   1 +
>  samples/landlock/Makefile      |  16 ++
>  samples/landlock/sandbox.c     | 405 +++++++++++++++++++++++++++++++++=
++++
>  security/Kconfig               |   1 +
>  security/Makefile              |   2 +
>  security/landlock/Kconfig      |  23 +++
>  security/landlock/Makefile     |   3 +
>  security/landlock/checker_fs.c | 152 ++++++++++++++
>  security/landlock/checker_fs.h |  20 ++
>  security/landlock/common.h     |  58 ++++++
>  security/landlock/lsm.c        | 449 +++++++++++++++++++++++++++++++++=
++++++++
>  security/landlock/manager.c    | 379 +++++++++++++++++++++++++++++++++=
+
>  security/security.c            |   1 +
>  35 files changed, 2309 insertions(+), 96 deletions(-)
>  create mode 100644 include/linux/landlock.h
>  create mode 100644 samples/landlock/.gitignore
>  create mode 100644 samples/landlock/Makefile
>  create mode 100644 samples/landlock/sandbox.c
>  create mode 100644 security/landlock/Kconfig
>  create mode 100644 security/landlock/Makefile
>  create mode 100644 security/landlock/checker_fs.c
>  create mode 100644 security/landlock/checker_fs.h
>  create mode 100644 security/landlock/common.h
>  create mode 100644 security/landlock/lsm.c
>  create mode 100644 security/landlock/manager.c
>=20


--FnL08gngGMavEQjuGawjk41AiTbXK9r4u--

--hpsVurOuKbeg3J1T6mBC2GeC9sDO0c6ig
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlgod2oACgkQIt7+33O9
apXpewf/Twz/ze04pNApWkpZo3C4L1I/qiJHqMC5huHlnTt3L9VjBmjoOGV/bF1b
qcIsRl6lYC/lJ+GWb5GYX3uneejgfTZRS2nKb/jiqSo7DERoc0m8h1DBjEQmletX
86bJSdEAymnQ2FD/VUtPXqbworkTkrBltDJJ8+2llOHuMaMeWXlvNs80Sy6eA1X4
xC/UX0r25RETsTa2whuCTpTnaOw84tQG6Iea9bhUW6ODf0SJuXCsXMCnXPSpmZZJ
ufq4mzznD7gsI+cpLF6s54FhFdQS6tbWnOAseMDSFuq2B0nvGEQsQytN9LRklu1D
njinSeXWPXt/GdhNP4Kxug8VOxwRtg==
=d6vO
-----END PGP SIGNATURE-----

--hpsVurOuKbeg3J1T6mBC2GeC9sDO0c6ig--
