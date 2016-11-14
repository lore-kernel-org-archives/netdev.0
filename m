From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Mon, 14 Nov 2016 02:35:55 -0800
Message-ID: <CAMp4zn8u3kg-nhiZ5rSUCLGveAzHr6FoP1x=iJasF2W0S56WfA@mail.gmail.com>
References: <20161026065654.19166-1-mic@digikod.net> <5828776A.1010104@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:CONTROL GROUP (CGRO
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5828776A.1010104-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2016 at 6:23 AM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> Hi,
>
> After the BoF at LPC last week, we came to a multi-step roadmap to
> upstream Landlock.
>
> A first patch series containing the basic properties needed for a
> "minimum viable product", which means being able to test it, without
> full features. The idea is to set in place the main components which
> include the LSM part (some hooks with the manager logic) and the new
> eBPF type. To have a minimum amount of code, the first userland entry
> point will be the seccomp syscall. This doesn't imply non-upstream
> patches and should be more simple. For the sake of simplicity and to
> ease the review, this first series will only be dedicated to privileged
> processes (i.e. with CAP_SYS_ADMIN). We may want to only allow one level
> of rules at first, instead of dealing with more complex rule inheritance
> (like seccomp-bpf can do).
>
> The second series will focus on the cgroup manager. It will follow the
> same rules of inheritance as the Daniel Mack's patches does.
>
> The third series will try to bring a BPF map of handles for Landlock and
> the dedicated BPF helpers.
>
> Finally, the fourth series will bring back the unprivileged mode (with
> no_new_privs), at least for process hierarchies (via seccomp). This also
> imply to handle multi-level of rules.
>
> Right now, an important point of attention is the userland ABI. We don't
> want LSM hooks to be exposed "as is" to userland. This may have some
> future implications if their semantic and/or enforcement point(s)
> change. In the next series, I will propose a new abstraction over the
> currently used LSM hooks. I'll also propose a new way to deal with
> resource accountability. Finally, I plan to create a minimal (kernel)
> developer documentation and a test suite.
>
> Regards,
>  Micka=C3=ABl
>
>
> On 26/10/2016 08:56, Micka=C3=ABl Sala=C3=BCn wrote:
>> Hi,
>>
>> This fourth RFC brings some improvements over the previous one [1]. An i=
mportant
>> new point is the abstraction from the raw types of LSM hook arguments. I=
t is
>> now possible to call a Landlock function the same way for LSM hooks with
>> different internal argument types. Some parts of the code are revamped w=
ith RCU
>> to properly deal with concurrency. From a userland point of view, the on=
ly
>> remaining link with seccomp-bpf is the ability to use the seccomp(2) sys=
call to
>> load and enforce a Landlock rule. Seccomp filters cannot trigger Landloc=
k rules
>> anymore. For now, it is no more possible for an unprivileged user to enf=
orce a
>> Landlock rule on a cgroup through delegation.
>>
>> As suggested, I plan to write documentation for userland and kernel deve=
lopers
>> with some kind of guiding principles. A remaining question is how to enf=
orce
>> limitations for the rule creation?
>>
>>
>> # Landlock LSM
>>
>> The goal of this new stackable Linux Security Module (LSM) called Landlo=
ck is
>> to allow any process, including unprivileged ones, to create powerful se=
curity
>> sandboxes comparable to the Seatbelt/XNU Sandbox or the OpenBSD Pledge. =
This
>> kind of sandbox is expected to help mitigate the security impact of bugs=
 or
>> unexpected/malicious behaviors in userland applications.
>>
>> eBPF programs are used to create a security rule. They are very limited =
(i.e.
>> can only call a whitelist of functions) and cannot do a denial of servic=
e (i.e.
>> no loop). A new dedicated eBPF map allows to collect and compare Landloc=
k
>> handles with system resources (e.g. files or network connections).
>>
>> The approach taken is to add the minimum amount of code while still allo=
wing
>> the userland to create quite complex access rules. A dedicated security =
policy
>> language as the one used by SELinux, AppArmor and other major LSMs invol=
ves a
>> lot of code and is usually dedicated to a trusted user (i.e. root).
>>
>>
>> # eBPF
>>
>> To get an expressive language while still being safe and small, Landlock=
 is
>> based on eBPF. Landlock should be usable by untrusted processes and must=
 then
>> expose a minimal attack surface. The eBPF bytecode is minimal while powe=
rful,
>> widely used and designed to be used by not so trusted application. Reusi=
ng this
>> code allows to not reproduce the same mistakes and minimize new code  wh=
ile
>> still taking a generic approach. Only a few additional features are adde=
d like
>> a new kind of arraymap and some dedicated eBPF functions.
>>
>> An eBPF program has access to an eBPF context which contains the LSM hoo=
k
>> arguments (as does seccomp-bpf with syscall arguments). They can be used
>> directly or passed to helper functions according to their types. It is t=
hen
>> possible to do complex access checks without race conditions nor inconsi=
stent
>> evaluation (i.e. incorrect mirroring of the OS code and state [2]).
>>
>> There is one eBPF program subtype per LSM hook. This allows to staticall=
y check
>> which context access is performed by an eBPF program. This is needed to =
deny
>> kernel address leak and ensure the right use of LSM hook arguments with =
eBPF
>> functions. Moreover, this safe pointer handling removes the need for run=
time
>> check or abstract data, which improves performances. Any user can add mu=
ltiple
>> Landlock eBPF programs per LSM hook. They are stacked and evaluated one =
after
>> the other (cf. seccomp-bpf).
>>
>>
>> # LSM hooks
>>
>> Unlike syscalls, LSM hooks are security checkpoints and are not architec=
ture
>> dependent. They are designed to match a security need associated with a
>> security policy (e.g. access to a file). Exposing parts of some LSM hook=
s
>> instead of using the syscall API for sandboxing should help to avoid bug=
s and
>> hacks as encountered by the first RFC. Instead of redoing the work of th=
e LSM
>> hooks through syscalls, we should use and expose them as does policies o=
f
>> access control LSM.
>>
>> Only a subset of the hooks are meaningful for an unprivileged sandbox me=
chanism
>> (e.g. file system or network access control). Landlock uses an abstracti=
on of
>> raw LSM hooks, which allow to deal with possible future API changes of t=
he LSM
>> hook API. Moreover, thanks to the ePBF program typing (per LSM hook) use=
d by
>> Landlock, it should not be hard to make such evolutions backward compati=
ble.
>>
>>
>> # Use case scenario
>>
>> First, a process needs to create a new dedicated eBPF map containing han=
dles.
>> This handles are references to system resources (e.g. file or directory)=
 and
>> grouped in one or multiple maps to be efficiently managed and checked in
>> batches. This kind of map can be passed to Landlock eBPF functions to co=
mpare,
>> for example, with a file access request. The handles are only accessible=
 from
>> the eBPF programs created by the same thread.
>>
>> The loaded Landlock eBPF programs can be triggered by a seccomp filter
>> returning RET_LANDLOCK. In addition, a cookie (16-bit value) can be pass=
ed from
>> a seccomp filter to eBPF programs. This allow flexible security policies
>> between seccomp and Landlock.
>>
>> Another way to enforce a Landlock security policy is to attach Landlock
>> programs to a dedicated cgroup. All the processes in this cgroup will th=
en be
>> subject to this policy. For unprivileged processes, this can be done tha=
nks to
>> cgroup delegation.
>>
>> A triggered Landlock eBPF program can allow or deny an access, according=
 to
>> its subtype (i.e. LSM hook), thanks to errno return values.
>>
>>
>> # Sandbox example with process hierarchy sandboxing (seccomp)
>>
>>   $ ls /home
>>   user1
>>   $ LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>>       ./samples/landlock/sandbox /bin/sh -i
>>   Launching a new sandboxed process.
>>   $ ls /home
>>   ls: cannot access '/home': No such file or directory
>>
>>
>> # Sandbox example with conditional access control depending on a cgroup
>>
>>   $ mkdir /sys/fs/cgroup/sandboxed
>>   $ ls /home
>>   user1
>>   $ LANDLOCK_CGROUPS=3D'/sys/fs/cgroup/sandboxed' \
>>       LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>>       ./samples/landlock/sandbox
>>   Ready to sandbox with cgroups.
>>   $ ls /home
>>   user1
>>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>>   $ ls /home
>>   ls: cannot access '/home': No such file or directory
>>
>>
>> # Current limitations and possible improvements
>>
>> For now, eBPF programs can only return an errno code. It may be interest=
ing to
>> be able to do other actions like seccomp-bpf does (e.g. kill process). S=
uch
>> features can easily be implemented but the main advantage of the current
>> approach is to be able to only execute eBPF programs until one returns a=
n errno
>> code instead of executing all programs like seccomp-bpf does.
>>
>> It is quite easy to add new eBPF functions to extend Landlock. The main =
concern
>> should be about the possibility to leak information from current process=
 to
>> another one (e.g. through maps) to not reproduce the same security sensi=
tive
>> behavior as ptrace.
>>
>> This design does not seem too intrusive but is flexible enough to allow =
a
>> powerful sandbox mechanism accessible by any process on Linux. The use o=
f
>> seccomp and Landlock is more suitable with the help of a userland librar=
y (e.g.
>> libseccomp) that could help to specify a high-level language to express =
a
>> security policy instead of raw eBPF programs. Moreover, thanks to LLVM, =
it is
>> possible to express an eBPF program with a subset of C.
>>
>>
>> # FAQ
>>
>> ## Why does seccomp-bpf is not enough?
>>
>> A seccomp filter can access to raw syscall arguments which means that it=
 is not
>> possible to filter according to pointed such as a file path. As the firs=
t
>> version of this patch series demonstrated, filtering at the syscall leve=
l is
>> complicated (e.g. need to take care of race conditions). This is mainly =
because
>> the access control checkpoints of the kernel are not at this high-level =
but
>> more underneath, at LSM hooks level. The LSM hooks are designed to handl=
e this
>> kind of checks. This series use this approach to leverage the ability of
>> unprivileged users to limit themselves.
>>
>> Cf. "What it isn't?" in Documentation/prctl/seccomp_filter.txt
>>
>>
>> ## Why using the seccomp(2) syscall?
>>
>> Landlock use the same semantic as seccomp to apply access rule restricti=
ons. It
>> add a new layer of security for the current process which is inherited b=
y its
>> childs. It makes sense to use an unique access-restricting syscall (that=
 should
>> be allowed by seccomp-bpf rules) which can only drop privileges. Moreove=
r, a
>> Landlock eBPF program could come from outside a process (e.g. passed thr=
ough a
>> UNIX socket). It is then useful to differentiate the creation/load of La=
ndlock
>> eBPF programs via bpf(2), from rule enforcing via seccomp(2).
>>
>>
>> ## Why using cgroups?
>>
>> cgroups are designed to handle groups of processes. One use case is to m=
anage
>> containers. Sandboxing based on process hierarchy (seccomp) is design to=
 handle
>> immutable security policies, which is a good security property but does =
not
>> match all use cases. A user can attach Landlock rules to a cgroup. Doing=
 so,
>> all the processes in that cgroup will be subject to the security policy.
>> However, if the user is allowed to manage this cgroup, it could dynamica=
lly
>> move this group of processes to a cgroup with another security policy (o=
r
>> none). Landlock rules can be applied either on a process hierarchy (e.g.
>> application with built-in sandboxing) or a group of processes (e.g. cont=
ainer
>> sandboxing). Both approaches can be combined for the same process.
>>
>>
>> ## Does Landlock can limit network access or other resources?
>>
>> Limiting network access is obviously in the scope of Landlock but it is =
not yet
>> implemented. The main goal now is to get feedback about the whole concep=
t, the
>> API and the file access control part. More access control types could be
>> implemented in the future.
>>
>> Sargun Dhillon sent a RFC (Checmate) [4] to deal with network manipulati=
on.
>> This could be implemented on top of the Landlock framework.
>>
>>
>> ## Why a new LSM? Are SELinux, AppArmor, Smack or Tomoyo not good enough=
?
>>
>> The current access control LSMs are fine for their purpose which is to g=
ive the
>> *root* the ability to enforce a security policy for the *system*. What i=
s
>> missing is a way to enforce a security policy for any applications by it=
s
>> developer and *unprivileged user* as seccomp can do for raw syscall filt=
ering.
>> Moreover, Landlock handles stacked hook programs from different users. I=
t must
>> then ensure there is no possible malicious interactions between these pr=
ograms.
>>
>> Differences with other (access control) LSMs:
>> * not only dedicated to administrators (i.e. no_new_priv);
>> * limited kernel attack surface (e.g. policy parsing);
>> * helpers to compare complex objects (path/FD), no access to internal ke=
rnel
>>   data (do not leak addresses);
>> * constrained policy rules/programs (no DoS: deterministic execution tim=
e);
>> * do not leak more information than the loader process can legitimately =
have
>>   access to (minimize metadata inference): must compare from an already =
allowed
>>   file (through a handle).
>>
>>
>> ## Why not use a policy language like used by SElinux or AppArmor?
>>
>> This kind of LSMs are dedicated to administrators. They already manage t=
he
>> system and are not a threat to the system security. However, seccomp, an=
d
>> Landlock too, should be available to anyone, which potentially include
>> untrusted users and processes. To reduce the attack surface, Landlock sh=
ould
>> expose the minimum amount of code, hence minimal complexity. Moreover, a=
nother
>> threat is to make accessible to a malicious code a new way to gain more
>> information. For example, Landlock features should not allow a program t=
o get
>> the file owner if the directory containing this file is not readable. Th=
is data
>> could then be exfiltrated thanks to the access result. Thus, we should l=
imit
>> the expressiveness of the available checks. The current approach is to d=
o the
>> checks in such a way that only a comparison with an already accessed res=
ource
>> (e.g. file descriptor) is possible. This allow to have a reference to co=
mpare
>> with, without exposing much information.
>>
>>
>> ## As a developer, why do I need this feature?
>>
>> Landlock's goal is to help userland to limit its attack surface.
>> Security-conscious developers would like to protect users from a securit=
y bug
>> in their applications and the third-party dependencies they are using. S=
uch a
>> bug can compromise all the user data and help an attacker to perform a
>> privilege escalation. Using an *unprivileged sandbox* feature such as La=
ndlock
>> empowers the developer with the ability to properly compartmentalize its
>> software and limit the impact of vulnerabilities.
>>
>>
>> ## As a user, why do I need a this feature?
>>
>> Any user can already use seccomp-bpf to whitelist a set of syscalls to
>> reduce the kernel attack surface for a predefined set of processes. Howe=
ver an
>> unprivileged user can't create a security policy like the root user can =
thanks to
>> SELinux and other access control LSMs. Landlock allows any unprivileged =
user to
>> protect their data from being accessed by any process they run but only =
an
>> identified subset. User tools can be created to help create such a high-=
level
>> access control policy. This policy may not be powerful enough to express=
 the
>> same policies as the current access control LSMs, because of the threat =
an
>> unprivileged user can be to the system, but it should be enough for most
>> use-cases (e.g. blacklist or whitelist a set of file hierarchies).
>>
>>
>> # Changes since RFC v3
>>
>> * use abstract LSM hook arguments with custom types (e.g. *_LANDLOCK_ARG=
_FS for
>>   struct file, struct inode and struct path)
>> * add more LSM hooks to support full file system access control
>> * improve the sandbox example
>> * fix races and RCU issues:
>>   * eBPF program execution and eBPF helpers
>>   * revamp the arraymap of handles to cleanly deal with update/delete
>> * eBPF program subtype for Landlock:
>>   * remove the "origin" field
>>   * add an "option" field
>> * rebase onto Daniel Mack's patches v7 [3]
>> * remove merged commit 1955351da41c ("bpf: Set register type according t=
o
>>   is_valid_access()")
>> * fix spelling mistakes
>> * cleanup some type and variable names
>> * split patches
>> * for now, remove cgroup delegation handling for unprivileged user
>> * remove extra access check for cgroup_get_from_fd()
>> * remove unused example code dealing with skb
>> * remove seccomp-bpf link:
>>   * no more seccomp cookie
>>   * for now, it is no more possible to check the current syscall propert=
ies
>>
>>
>> # Changes since RFC v2
>>
>> * revamp cgroup handling:
>>   * use Daniel Mack's patches "Add eBPF hooks for cgroups" v5
>>   * remove bpf_landlock_cmp_cgroup_beneath()
>>   * make BPF_PROG_ATTACH usable with delegated cgroups
>>   * add a new CGRP_NO_NEW_PRIVS flag for safe cgroups
>>   * handle Landlock sandboxing for cgroups hierarchy
>>   * allow unprivileged processes to attach Landlock eBPF program to cgro=
ups
>> * add subtype to eBPF programs:
>>   * replace Landlock hook identification by custom eBPF program types wi=
th a
>>     dedicated subtype field
>>   * manage fine-grained privileged Landlock programs
>>   * register Landlock programs for dedicated trigger origins (e.g. sysca=
ll,
>>     return from seccomp filter and/or interruption)
>> * performance and memory optimizations: use an array to access Landlock =
hooks
>>   directly but do not duplicated it for each thread (seccomp-based)
>> * allow running Landlock programs without seccomp filter
>> * fix seccomp-related issues
>> * remove extra errno bounding check for Landlock programs
>> * add some examples for optional eBPF functions or context access (netwo=
rk
>>   related) according to security checks to allow more features for privi=
leged
>>   programs (e.g. Checmate)
>>
>>
>> # Changes since RFC v1
>>
>> * focus on the LSM hooks, not the syscalls:
>>   * much more simple implementation
>>   * does not need audit cache tricks to avoid race conditions
>>   * more simple to use and more generic because using the LSM hook abstr=
action
>>     directly
>>   * more efficient because only checking in LSM hooks
>>   * architecture agnostic
>> * switch from cBPF to eBPF:
>>   * new eBPF program types dedicated to Landlock
>>   * custom functions used by the eBPF program
>>   * gain some new features (e.g. 10 registers, can load values of differ=
ent
>>       size, LLVM translator) but only a few functions allowed and a dedi=
cated map
>>     type
>>   * new context: LSM hook ID, cookie and LSM hook arguments
>>   * need to set the sysctl kernel.unprivileged_bpf_disable to 0 (default=
 value)
>>     to be able to load hook filters as unprivileged users
>> * smaller and simpler:
>>   * no more checker groups but dedicated arraymap of handles
>>   * simpler userland structs thanks to eBPF functions
>> * distinctive name: Landlock
>>
>>
>> This series can be applied on top of Daniel Mack's patches for BPF_PROG_=
ATTACH
>> v7 [3] on Linux v4.9-rc2. This can be tested with CONFIG_SECURITY_LANDLO=
CK,
>> CONFIG_SECCOMP_FILTER and CONFIG_CGROUP_BPF. I would really appreciate
>> constructive comments on the usability, architecture, code and userland =
API of
>> Landlock LSM.
>>
>> [1] https://lkml.kernel.org/r/20160914072415.26021-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org
>> [2] https://crypto.stanford.edu/cs155/papers/traps.pdf
>> [3] https://lkml.kernel.org/r/1477390454-12553-1-git-send-email-daniel@z=
onque.org
>> [4] https://lkml.kernel.org/r/20160829114542.GA20836-I4sfFR6g6EicJoAdRrHjTitQHAD/DGy2@public.gmane.org=
bus-611.internal
>>
>> Regards,
>>
>> Micka=C3=ABl Sala=C3=BCn (18):
>>   landlock: Add Kconfig
>>   bpf: Move u64_to_ptr() to BPF headers and inline it
>>   bpf,landlock: Add a new arraymap type to deal with (Landlock) handles
>>   bpf,landlock: Add eBPF program subtype and is_valid_subtype() verifier
>>   bpf,landlock: Define an eBPF program type for Landlock
>>   fs: Constify path_is_under()'s arguments
>>   landlock: Add LSM hooks
>>   landlock: Handle file comparisons
>>   landlock: Add manager functions
>>   seccomp: Split put_seccomp_filter() with put_seccomp()
>>   seccomp,landlock: Handle Landlock hooks per process hierarchy
>>   bpf: Cosmetic change for bpf_prog_attach()
>>   bpf/cgroup: Replace struct bpf_prog with struct bpf_object
>>   bpf/cgroup: Make cgroup_bpf_update() return an error code
>>   bpf/cgroup: Move capability check
>>   bpf/cgroup,landlock: Handle Landlock hooks per cgroup
>>   landlock: Add update and debug access flags
>>   samples/landlock: Add sandbox example
>>
>>  fs/namespace.c                 |   2 +-
>>  include/linux/bpf-cgroup.h     |  19 +-
>>  include/linux/bpf.h            |  44 +++-
>>  include/linux/cgroup-defs.h    |   2 +
>>  include/linux/filter.h         |   1 +
>>  include/linux/fs.h             |   2 +-
>>  include/linux/landlock.h       |  95 +++++++++
>>  include/linux/lsm_hooks.h      |   5 +
>>  include/linux/seccomp.h        |  12 +-
>>  include/uapi/linux/bpf.h       | 105 ++++++++++
>>  include/uapi/linux/seccomp.h   |   1 +
>>  kernel/bpf/arraymap.c          | 270 +++++++++++++++++++++++++
>>  kernel/bpf/cgroup.c            | 139 ++++++++++---
>>  kernel/bpf/syscall.c           |  71 ++++---
>>  kernel/bpf/verifier.c          |  35 +++-
>>  kernel/cgroup.c                |   6 +-
>>  kernel/fork.c                  |  15 +-
>>  kernel/seccomp.c               |  26 ++-
>>  kernel/trace/bpf_trace.c       |  12 +-
>>  net/core/filter.c              |  26 ++-
>>  samples/Makefile               |   2 +-
>>  samples/bpf/bpf_helpers.h      |   5 +
>>  samples/landlock/.gitignore    |   1 +
>>  samples/landlock/Makefile      |  16 ++
>>  samples/landlock/sandbox.c     | 405 ++++++++++++++++++++++++++++++++++=
+++
>>  security/Kconfig               |   1 +
>>  security/Makefile              |   2 +
>>  security/landlock/Kconfig      |  23 +++
>>  security/landlock/Makefile     |   3 +
>>  security/landlock/checker_fs.c | 152 ++++++++++++++
>>  security/landlock/checker_fs.h |  20 ++
>>  security/landlock/common.h     |  58 ++++++
>>  security/landlock/lsm.c        | 449 ++++++++++++++++++++++++++++++++++=
+++++++
>>  security/landlock/manager.c    | 379 ++++++++++++++++++++++++++++++++++
>>  security/security.c            |   1 +
>>  35 files changed, 2309 insertions(+), 96 deletions(-)
>>  create mode 100644 include/linux/landlock.h
>>  create mode 100644 samples/landlock/.gitignore
>>  create mode 100644 samples/landlock/Makefile
>>  create mode 100644 samples/landlock/sandbox.c
>>  create mode 100644 security/landlock/Kconfig
>>  create mode 100644 security/landlock/Makefile
>>  create mode 100644 security/landlock/checker_fs.c
>>  create mode 100644 security/landlock/checker_fs.h
>>  create mode 100644 security/landlock/common.h
>>  create mode 100644 security/landlock/lsm.c
>>  create mode 100644 security/landlock/manager.c
>>
>

Was there a plan around getting Daniel's patches in as well? Also,
rather than making these handles landlock-specific, can they be
implemented in such a way where we can keep track of (some) of these
in other types of programs?
