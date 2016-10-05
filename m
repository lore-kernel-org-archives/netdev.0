From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with
 (Landlock) handles
Date: Thu, 6 Oct 2016 00:02:39 +0200
Message-ID: <57F5787F.4080003@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-4-mic@digikod.net>
 <CAGXu5jLgkbMN0KszLx3dcHfmksW_TORzT7JxHiGJL2Xux5TVBA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="UMSF8q0VeJ4cT4fShhe9p6XH73PoOoob6"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        linux-security-module <linux-s
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-4811-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jLgkbMN0KszLx3dcHfmksW_TORzT7JxHiGJL2Xux5TVBA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UMSF8q0VeJ4cT4fShhe9p6XH73PoOoob6
Content-Type: multipart/mixed; boundary="k51gAKIR2huTOmH33MJqK6dLkGniQ5FcA";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Paul Moore <pmoore@redhat.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 Cgroups <cgroups@vger.kernel.org>
Message-ID: <57F5787F.4080003@digikod.net>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with
 (Landlock) handles
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-4-mic@digikod.net>
 <CAGXu5jLgkbMN0KszLx3dcHfmksW_TORzT7JxHiGJL2Xux5TVBA@mail.gmail.com>
In-Reply-To: <CAGXu5jLgkbMN0KszLx3dcHfmksW_TORzT7JxHiGJL2Xux5TVBA@mail.gmail.com>

--k51gAKIR2huTOmH33MJqK6dLkGniQ5FcA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 04/10/2016 01:53, Kees Cook wrote:
> On Wed, Sep 14, 2016 at 12:23 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>> This new arraymap looks like a set and brings new properties:
>> * strong typing of entries: the eBPF functions get the array type of
>>   elements instead of CONST_PTR_TO_MAP (e.g.
>>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
>> * force sequential filling (i.e. replace or append-only update), which=

>>   allow quick browsing of all entries.
>>
>> This strong typing is useful to statically check if the content of a m=
ap
>> can be passed to an eBPF function. For example, Landlock use it to sto=
re
>> and manage kernel objects (e.g. struct file) instead of dealing with
>> userland raw data. This improve efficiency and ensure that an eBPF
>> program can only call functions with the right high-level arguments.
>>
>> The enum bpf_map_handle_type list low-level types (e.g.
>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
>> updating a map entry (handle). This handle types are used to infer a
>> high-level arraymap type which are listed in enum bpf_map_array_type
>> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
>>
>> For now, this new arraymap is only used by Landlock LSM (cf. next
>> commits) but it could be useful for other needs.
>>
>> Changes since v2:
>> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
>>   handle entries (suggested by Andy Lutomirski)
>> * remove useless checks
>>
>> Changes since v1:
>> * arraymap of handles replace custom checker groups
>> * simpler userland API
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Kees Cook <keescook@chromium.org>
>> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh7=
7FD2G5o71yD7g@mail.gmail.com
>> ---
>>  include/linux/bpf.h      |  14 ++++
>>  include/uapi/linux/bpf.h |  18 +++++
>>  kernel/bpf/arraymap.c    | 203 ++++++++++++++++++++++++++++++++++++++=
+++++++++
>>  kernel/bpf/verifier.c    |  12 ++-
>>  4 files changed, 246 insertions(+), 1 deletion(-)
>>
>> [...]
>> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
>> index a2ac051c342f..94256597eacd 100644
>> --- a/kernel/bpf/arraymap.c
>> +++ b/kernel/bpf/arraymap.c
>> [...]
>> +       /*
>> +        * Limit number of entries in an arraymap of handles to the ma=
ximum
>> +        * number of open files for the current process. The maximum n=
umber of
>> +        * handle entries (including all arraymaps) for a process is t=
hen
>> +        * (RLIMIT_NOFILE - 1) * RLIMIT_NOFILE. If the process' RLIMIT=
_NOFILE
>> +        * is 0, then any entry update is forbidden.
>> +        *
>> +        * An eBPF program can inherit all the arraymap FD. The worse =
case is
>> +        * to fill a bunch of arraymaps, create an eBPF program, close=
 the
>> +        * arraymap FDs, and start again. The maximum number of arraym=
ap
>> +        * entries can then be close to RLIMIT_NOFILE^3.
>> +        *
>> +        * FIXME: This should be improved... any idea?
>> +        */
>> +       if (unlikely(index >=3D rlimit(RLIMIT_NOFILE)))
>> +               return -EMFILE;
>=20
> I'm not sure what's best for resource management here. Landlock will
> be holding open path structs, for example, but how are you expecting
> to track things like network policies? An allowed IP address, for
> example, doesn't have a handle outside of doing a full
> socket()/connect() setup.

Path and file references are hard to handle correctly but other things
should be simpler. External resources (i.e. not relative to the running
system as paths are) like network hosts or ports could simply be
expressed as raw values (like used for iptables rules). Moreover, for
network rules, relying on raw packet values (as
BPF_PROG_TYPE_SOCKET_FILTER have access to) may be more than enough.

>=20
> I think an explicit design for resource management should be
> considered up front...

I'm not really sure how to handle that part=E2=80=A6

There is basically two ways to express a "kernel object": relative (with
an internal pointer to a struct, e.g. struct file) or absolute (a raw
value). Both of them use kernel memory. However, only the former may
impact other parts of the kernel (e.g. can force to hold a kernel object
like a struct dentry). The impact of this is not clear for me but it
looks like other resource managements for a process: number of open
files, number of network connections=E2=80=A6

The more reasonable approach seems to charge the user for the (kernel)
memory dedicated to the user's policy. How can I do it? Maybe to
decrement the RLIMIT_NPROC and check the RLIMIT_AS (i.e. act like a
virtual process)?

There is no such limits with other eBPF maps (even those dealing with
FD), so this may be too much.

 Micka=C3=ABl


--k51gAKIR2huTOmH33MJqK6dLkGniQ5FcA--

--UMSF8q0VeJ4cT4fShhe9p6XH73PoOoob6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX9XiAAAoJECLe/t9zvWqVlEQH/1aQknK9+WA+KKKozNc/SHQi
9g/ggenePeSpHlUyob024n5HYcMO9PO8QzMb7TbNLJYXyWPL7tBis1Q0ToEv1vh0
2pGcY+jK4le8nK02zj8qC7v6HhTGUhDoxl/Yyq1QjWTmOTQ7rXXpazz2IR0M/dd4
pCrP04cz6BPo/IYO3YQcuslUyFGmwUjYKCMMlPpP4XwID8zw6Drr7TDInSJlDs57
ZhlqaI9MQ5UtwC8LOaEbE+RaH6ueMRzioM83eukYLCaxHeYnQwLxqej5DrTiPxWw
Jtv4t87ZPrREMUBdXrtVBT6ohWFck6k3f3AUoukjBrhkXMciEvJgD6tUtIFNW0Y=
=N7p6
-----END PGP SIGNATURE-----

--UMSF8q0VeJ4cT4fShhe9p6XH73PoOoob6--
