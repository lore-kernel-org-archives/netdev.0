From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Wed, 1 Mar 2017 23:14:09 +0100
Message-ID: <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="X2djGIEVvP6fHO8XnsDwtXmWf3j50W7US"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale
 <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-6878-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--X2djGIEVvP6fHO8XnsDwtXmWf3j50W7US
Content-Type: multipart/mixed; boundary="CFCaR7wdluXHGWWwRhH5I341KSkm3wODs";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
In-Reply-To: <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>

--CFCaR7wdluXHGWWwRhH5I341KSkm3wODs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 28/02/2017 21:01, Andy Lutomirski wrote:
> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> The seccomp(2) syscall can be use to apply a Landlock rule to the
>> current process. As with a seccomp filter, the Landlock rule is enforc=
ed
>> for all its future children. An inherited rule tree can be updated
>> (append-only) by the owner of inherited Landlock nodes (e.g. a parent
>> process that create a new rule)
>=20
> Can you clarify exaclty what this type of update does?  Is it
> something that should be supported by normal seccomp rules as well?

There is two main structures involved here: struct landlock_node and
struct landlock_rule, both defined in include/linux/landlock.h [02/10].

Let's take an example with seccomp filter and then Landlock:
* seccomp filter: Process P1 creates and applies a seccomp filter F1 to
itself. Then it forks and creates a child P2, which inherits P1's
filters, hence F1. Now, if P1 add a new seccomp filter F2 to itself, P2
*won't get it*. The P2's filter list will still only contains F1 but not
F2. If P2 sets up and applies a new filter F3 to itself, its filter list
will contains F1 and F3.
* Landlock: Process P1 creates and applies a Landlock rule R1 to itself.
Underneath the kernel creates a new node N1 dedicated to P1, which
contains all its rules. Then P1 forks and creates a child P2, which
inherits P1's rules, hence R1. Underneath P2 inherited N1. Now, if P1
add a new Landlock rule R2 to itself, P2 *will get it* as well (because
R2 is part of N1). If P2 creates and applies a new rule R3 to itself,
its rules will contains R1, R2 and R3. Underneath the kernel created a
new node N2 for P2, which only contains R3 but inherits/links to N1.

This design makes it possible for a process to add more constraints to
its children on the fly. I think it is a good feature to have and a
safer default inheritance mechanism, but it could be guarded by an
option flag if we want both mechanism to be available. The same design
could be used by seccomp filter too.


>=20
>> +/**
>> + * landlock_run_prog - run Landlock program for a syscall
>=20
> Unless this is actually specific to syscalls, s/for a syscall//, perhap=
s?

Right, not specific to syscall anymore.

>=20
>> +               if (new_events->nodes[event_idx]->owner =3D=3D
>> +                               &new_events->nodes[event_idx]) {
>> +                       /* We are the owner, we can then update the no=
de. */
>> +                       add_landlock_rule(new_events, rule);
>=20
> This is the part I don't get.  Adding a rule if you're the owner (BTW,
> why is ownership visible to userspace at all?) for just yourself and
> future children is very different from adding it so it applies to
> preexisting children too.

Node ownership is not (directly) visible to userspace.

The current inheritance mechanism doesn't enable to only add a rule to
the current process. The rule will be inherited by its children
(starting from the children created after the first applied rule). An
option flag NEW_RULE_HIERARCHY (or maybe another seccomp operation)
could enable to create a new node for the current process, and then
makes it not inherited by the previous children.


>=20
>=20
>> +               } else if (atomic_read(&current_events->usage) =3D=3D =
1) {
>> +                       WARN_ON(new_events->nodes[event_idx]->owner);
>> +                       /*
>> +                        * We can become the new owner if no other tas=
k use it.
>> +                        * This avoid an unnecessary allocation.
>> +                        */
>> +                       new_events->nodes[event_idx]->owner =3D
>> +                               &new_events->nodes[event_idx];
>> +                       add_landlock_rule(new_events, rule);
>> +               } else {
>> +                       /*
>> +                        * We are not the owner, we need to fork curre=
nt_events
>> +                        * and then add a new node.
>> +                        */
>> +                       struct landlock_node *node;
>> +                       size_t i;
>> +
>> +                       node =3D kmalloc(sizeof(*node), GFP_KERNEL);
>> +                       if (!node) {
>> +                               new_events =3D ERR_PTR(-ENOMEM);
>> +                               goto put_rule;
>> +                       }
>> +                       atomic_set(&node->usage, 1);
>> +                       /* set the previous node after the new_events
>> +                        * allocation */
>> +                       node->prev =3D NULL;
>> +                       /* do not increment the previous node usage */=

>> +                       node->owner =3D &new_events->nodes[event_idx];=

>> +                       /* rule->prev is already NULL */
>> +                       atomic_set(&rule->usage, 1);
>> +                       node->rule =3D rule;
>> +
>> +                       new_events =3D new_raw_landlock_events();
>> +                       if (IS_ERR(new_events)) {
>> +                               /* put the rule as well */
>> +                               put_landlock_node(node);
>> +                               return ERR_PTR(-ENOMEM);
>> +                       }
>> +                       for (i =3D 0; i < ARRAY_SIZE(new_events->nodes=
); i++) {
>> +                               new_events->nodes[i] =3D
>> +                                       lockless_dereference(
>> +                                                       current_events=
->nodes[i]);
>> +                               if (i =3D=3D event_idx)
>> +                                       node->prev =3D new_events->nod=
es[i];
>> +                               if (!WARN_ON(!new_events->nodes[i]))
>> +                                       atomic_inc(&new_events->nodes[=
i]->usage);
>> +                       }
>> +                       new_events->nodes[event_idx] =3D node;
>> +
>> +                       /*
>> +                        * @current_events will not be freed here beca=
use it's usage
>> +                        * field is > 1. It is only prevented to be fr=
eed by another
>> +                        * subject thanks to the caller of landlock_ap=
pend_prog() which
>> +                        * should be locked if needed.
>> +                        */
>> +                       put_landlock_events(current_events);
>> +               }
>> +       }
>> +       return new_events;
>> +
>> +put_prog:
>> +       bpf_prog_put(prog);
>> +       return new_events;
>> +
>> +put_rule:
>> +       put_landlock_rule(rule);
>> +       return new_events;
>> +}
>> +
>> +/**
>> + * landlock_seccomp_append_prog - attach a Landlock rule to the curre=
nt process
>> + *
>> + * current->seccomp.landlock_events is lazily allocated. When a proce=
ss fork,
>> + * only a pointer is copied. When a new event is added by a process, =
if there
>> + * is other references to this process' landlock_events, then a new a=
llocation
>> + * is made to contains an array pointing to Landlock rule lists. This=
 design
>> + * has low-performance impact and is memory efficient while keeping t=
he
>> + * property of append-only rules.
>> + *
>> + * @flags: not used for now, but could be used for TSYNC
>> + * @user_bpf_fd: file descriptor pointing to a loaded Landlock rule
>> + */
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +int landlock_seccomp_append_prog(unsigned int flags, const char __use=
r *user_bpf_fd)
>> +{
>> +       struct landlock_events *new_events;
>> +       struct bpf_prog *prog;
>> +       int bpf_fd;
>> +
>> +       /* force no_new_privs to limit privilege escalation */
>> +       if (!task_no_new_privs(current))
>> +               return -EPERM;
>> +       /* will be removed in the future to allow unprivileged tasks *=
/
>> +       if (!capable(CAP_SYS_ADMIN))
>> +               return -EPERM;
>> +       if (!user_bpf_fd)
>> +               return -EFAULT;
>> +       if (flags)
>> +               return -EINVAL;
>> +       if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(bpf_fd)))
>> +               return -EFAULT;
>> +       prog =3D bpf_prog_get(bpf_fd);
>> +       if (IS_ERR(prog))
>> +               return PTR_ERR(prog);
>> +
>> +       /*
>> +        * We don't need to lock anything for the current process hier=
archy,
>> +        * everything is guarded by the atomic counters.
>> +        */
>> +       new_events =3D landlock_append_prog(current->seccomp.landlock_=
events, prog);
>=20
> Do you need to check that it's the right *kind* of bpf prog or is that
> handled elsewhere?

The program type is checked at the beginning of landlock_append_prog().

 Micka=C3=ABl


--CFCaR7wdluXHGWWwRhH5I341KSkm3wODs--

--X2djGIEVvP6fHO8XnsDwtXmWf3j50W7US
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAli3R7EACgkQIt7+33O9
apX8QAf/eI3atDp18pPFBGV9RX9sr9mKWtJm/16KS6847V1P7fhZna7RImu9Ccxn
fYE9p0tkc4FU+L2hscnvzAJx63Ku3nnxsR4APbaAU6WprKB6wXdbRXvwFjA8uXC6
NnbORbV5BQUXwlzXA4ftUQkhGzOfHDrNG8iBFroqgOtpQqaHtWDw6XVqCJ1y0pNk
+BhWM236jl1xQ5wmX/qI3y9qe/Exdg3AP6AQz2yuuIs4g9K3vLMAdCAZMn2/UejF
KV7rrrtKe67p3yndszGS/lh9e4GwYvt5c17WKs9vttasrLLLsD4X1On12dW8tqaV
8ox9iXx1jCYQKGTKfkAArMPn5Q6g6Q==
=fusf
-----END PGP SIGNATURE-----

--X2djGIEVvP6fHO8XnsDwtXmWf3j50W7US--
