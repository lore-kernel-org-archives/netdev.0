From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Thu, 25 Aug 2016 16:44:13 +0200
Message-ID: <57BF043D.4000300@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fem93Duixaa7Puv1lVjAwOLiiCPLhog68"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
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
        Network Development <netdev@vger.kernel.org>, cgroups@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4468-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fem93Duixaa7Puv1lVjAwOLiiCPLhog68
Content-Type: multipart/mixed; boundary="k0jrAKmG3iFl0mLHQhvH5VcJm2i7BKQmS"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>, cgroups@vger.kernel.org
Message-ID: <57BF043D.4000300@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
In-Reply-To: <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>

--k0jrAKmG3iFl0mLHQhvH5VcJm2i7BKQmS
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 25/08/2016 13:09, Andy Lutomirski wrote:
> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)=

>> to compare the current process cgroup with a cgroup handle, The handle=

>> can match the current cgroup if it is the same or a child. This allows=

>> to make conditional rules according to the current cgroup.
>>
>> A cgroup handle is a map entry created from a file descriptor referrin=
g
>> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, t=
he
>> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
>> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.
>=20
> Can you elaborate on why this is useful?  I.e. why not just supply
> different policies to different subtrees.

The main use case I see is to load the security policies at the start of
a user session for all processes but not enforce them right away. The
user can then keep a shell for Landlock administration tasks and lock
the other processes with a dedicated cgroup on the fly. This allows the
user to make unremovable Landlock security policies but only activate
them when needed for specific processes.

>=20
> Also, how does this interact with the current cgroup v1 vs v2 mess?
> As far as I can tell, no one can even really agree on what "what
> cgroup am I in" means right now.

I tested with cgroup-v2 but indeed, it seems a bit different with
cgroup-v1 :)
Does anyone know how to handle both cases?

>=20
>>
>> An unprivileged process can create and manipulate cgroups thanks to
>> cgroup delegation.
>=20
> What is cgroup delegation?

This is simply the action of changing the owner of cgroup sysfs files to
allow an unprivileged user to handle them (cf. Documentation/cgroup-v2.tx=
t)

 Micka=C3=ABl


--k0jrAKmG3iFl0mLHQhvH5VcJm2i7BKQmS--

--fem93Duixaa7Puv1lVjAwOLiiCPLhog68
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXvwQ9AAoJECLe/t9zvWqVV9YH/2GeL+bwWnpzafOOxl7lEld5
zQKWjoYZ56f4+eGjV7hteNfRt7ZaubLQ7brmPDtX+p4z7/PentK+HcsXRI/5gyK0
FjtsATTSiH+xJiBDhH31FvYEsonHmH0CZsjWQGBiIUeJXVtUracGmJNsZf4WWiyF
IHGBZZ6Gdzir+DyZmcMjNLXmCXi1tLLdoV/51gdBxt9hUg/Tf+fkd1ILxdimo3Rc
oH5iyvJH65VycWFFm52nWZjBGvoy7rKZ8oxhiU2kt08P6TkYD3ENULho6b59BixL
iK801B96L/HbPckcTOgbWXBNYXI8LWbSLsoiilv9P5CYm5sPYHu7vJBg/IJdvCI=
=A8Yu
-----END PGP SIGNATURE-----

--fem93Duixaa7Puv1lVjAwOLiiCPLhog68--
