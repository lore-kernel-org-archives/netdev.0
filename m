From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Sat, 27 Aug 2016 17:10:45 +0200
Message-ID: <57C1AD75.8070304@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="hCX4i6hXjDhjiTdmg5e827IURbh9pcgg3"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        Kernel Hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4486-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hCX4i6hXjDhjiTdmg5e827IURbh9pcgg3
Content-Type: multipart/mixed; boundary="RUNMB3Xv3qUNgqbQDOUlkelbU2tKBwfBr"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <57C1AD75.8070304@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
In-Reply-To: <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>

--RUNMB3Xv3qUNgqbQDOUlkelbU2tKBwfBr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 09:40, Andy Lutomirski wrote:
> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> Hi,
>>
>> This series is a proof of concept to fill some missing part of seccomp=
 as the
>> ability to check syscall argument pointers or creating more dynamic se=
curity
>> policies. The goal of this new stackable Linux Security Module (LSM) c=
alled
>> Landlock is to allow any process, including unprivileged ones, to crea=
te
>> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or =
the
>> OpenBSD Pledge. This kind of sandbox help to mitigate the security imp=
act of
>> bugs or unexpected/malicious behaviors in userland applications.
>>
>> The first RFC [1] was focused on extending seccomp while staying at th=
e syscall
>> level. This brought a working PoC but with some (mitigated) ToCToU rac=
e
>> conditions due to the seccomp ptrace hole (now fixed) and the non-atom=
ic
>> syscall argument evaluation (hence the LSM hooks).
>>
>>
>> # Landlock LSM
>>
>> This second RFC is a fresh revamp of the code while keeping some worki=
ng ideas.
>> This series is mainly focused on LSM hooks, while keeping the possibil=
ity to
>> tied them to syscalls. This new code removes all race conditions by de=
sign. It
>> now use eBPF instead of a subset of cBPF (as used by seccomp-bpf). Thi=
s allow
>> to remove the previous stacked cBPF hack to do complex access checks t=
hanks to
>> dedicated eBPF functions. An eBPF program is still very limited (i.e. =
can only
>> call a whitelist of functions) and can not do a denial of service (i.e=
=2E no
>> loop). The other major improvement is the replacement of the previous =
custom
>> checker groups of syscall arguments with a new dedicated eBPF map to c=
ollect
>> and compare Landlock handles with system resources (e.g. files or netw=
ork
>> connections).
>>
>> The approach taken is to add the minimum amount of code while still al=
lowing
>> the userland to create quite complex access rules. A dedicated securit=
y policy
>> language such as used by SELinux, AppArmor and other major LSMs is a l=
ot of
>> code and dedicated to a trusted process (i.e. root/administrator).
>>
>=20
> I think there might be a problem with the current design.  If I add a
> seccomp filter that uses RET_LANDLOCK and some landlock filters, what
> happens if a second seccomp filter *also* uses RET_LANDLOCK?  I think
> they'll interfere with each other.  It might end up being necessary to
> require only one landlock seccomp layer at a time or to find a way to
> stick all the filters in a layer together with the LSM callbacks or
> maybe to just drop RET_LANDLOCK and let the callbacks look at the
> syscall args.

This is correctly managed. For each RET_LANDLOCK, if there is one or
more associated Landlock programs (i.e. created by the same thread after
this seccomp filters), there is one Landlock program instance run for
each seccomp that trigger them. This way, each cookie linked to a
RET_LANDLOCK is evaluated one time by each relevant Landlock program.

Example when a thread that loaded multiple seccomp filters (SF) and
multiple Landlock programs (LP) associated with one LSM hook: SF0, SF1,
LP0(file_open), SF2, LP1(file_open), LP2(file_permission)

* If SF0 returns RET_LANDLOCK(cookie0), then LP0 and LP1 are run with
cookie0 if the current syscall trigger the file_open hook, and LP2 is
run with cookie0 if the syscall trigger the file_permission hook.

* In addition to the previous case, if SF1 returns
RET_LANDLOCK(cookie1), then LP0 and LP1 are run with cookie1 if the
current syscall trigger the file_open hook, and LP2 is run with cookie1
if the syscall trigger the file_permission hook.

* In addition to the previous cases, if SF2 returns
RET_LANDLOCK(cookie2), then (only) LP1 is run with cookie2 if the
current syscall trigger the file_open hook, and LP2 is run with cookie2
if the syscall trigger the file_permission hook.


>=20
> BTW, what happens if an LSM hook is called outside a syscall context,
> e.g. from a page fault?

Good catch! For now, only a syscall can trigger an LSM hook because of
the RET_LANDLOCK constraint. It may be wise to trigger them without a
cookie and add a dedicated variable in the eBPF context.

>=20
>>
>>
>> # Sandbox example with conditional access control depending on cgroup
>>
>>   $ mkdir /sys/fs/cgroup/sandboxed
>>   $ ls /home
>>   user1
>>   $ LANDLOCK_CGROUPS=3D'/sys/fs/cgroup/sandboxed' \
>>       LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>>       ./sandbox /bin/sh -i
>>   $ ls /home
>>   user1
>>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>>   $ ls /home
>>   ls: cannot open directory '/home': Permission denied
>>
>=20
> Something occurs to me that isn't strictly relevant to landlock but
> may be relevant to unprivileged cgroups: can you cause trouble by
> setting up a nastily-configured cgroup and running a setuid program in
> it?
>=20

I hope not=E2=80=A6 But the use of cgroups should not be mandatory for La=
ndlock.


--RUNMB3Xv3qUNgqbQDOUlkelbU2tKBwfBr--

--hCX4i6hXjDhjiTdmg5e827IURbh9pcgg3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwa11AAoJECLe/t9zvWqVjEMH/3OdxPktDpLIzqN5Ji9M8X2o
DCh7AmaBHeIyD+ajc4m2nfCseAUmey7EiTgof1EwFr/2bGVQAok+fZYVG5KzjYLh
n5TUsfAcfv7CH8ciUwK0W5uygP1GivEIPN3EQ8n7H4S0epDH+kNibid6DtPhlfFm
dCvjkJdjj3gZDGOnjE+a8r1cJ+3ONmhGtQwsXAczo1PqEj56vYdAhZfz3CJghRC4
s4p8QQ7Q5xGnlVBKPsBJLrFHEtNeUq9OzHsif6hQV0iIbVHxTRZUFa9KTNf59G17
7dZrwyo4kw/C1pYYcdpdhjrBC4F4iU2ofv3mWAsDS5Uxw3VpTMkCBI99YFm84Bk=
=hmwZ
-----END PGP SIGNATURE-----

--hCX4i6hXjDhjiTdmg5e827IURbh9pcgg3--
