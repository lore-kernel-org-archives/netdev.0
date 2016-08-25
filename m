From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Thu, 25 Aug 2016 15:57:29 +0200
Message-ID: <57BEF949.6090808@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrW98g_x0US92+Qq8gkN1N+y21rjSXcGBR7nRd1hWU7AgQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Al6xw5FI9qr3UgJ4HsDw4rRlN4Qqoc78t"
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
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4466-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrW98g_x0US92+Qq8gkN1N+y21rjSXcGBR7nRd1hWU7AgQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Al6xw5FI9qr3UgJ4HsDw4rRlN4Qqoc78t
Content-Type: multipart/mixed; boundary="2HflmeHHgbTbeHlc69LqQTKE1mnqnoMgi"
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
 Network Development <netdev@vger.kernel.org>
Message-ID: <57BEF949.6090808@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrW98g_x0US92+Qq8gkN1N+y21rjSXcGBR7nRd1hWU7AgQ@mail.gmail.com>
In-Reply-To: <CALCETrW98g_x0US92+Qq8gkN1N+y21rjSXcGBR7nRd1hWU7AgQ@mail.gmail.com>

--2HflmeHHgbTbeHlc69LqQTKE1mnqnoMgi
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 25/08/2016 13:05, Andy Lutomirski wrote:
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
>=20
> Maybe I'm missing an obvious description, but: do you have a
> description of the eBPF API to landlock?  What function do you
> provide, when is it called, what functions can it call, what does the
> fancy new arraymap do, etc?
>=20
> --Andy
>=20

The eBPF context is described in "[RFC v2 06/10] landlock: Add LSM hooks"=
=2E

The provided eBPF functions are described in "[RFC v2 08/10] landlock:
Handle file system comparisons"
(bpf_landlock_cmp_fs_prop_with_struct_file and
bpf_landlock_cmp_fs_beneath_with_struct_file) and "[RFC v2 09/10]
landlock: Handle cgroups" (bpf_landlock_cmp_cgroup_beneath). The
function descriptions are summarized in include/uapi/linux/bpf.h .

This functions can be called by an eBPF program of type
BPF_PROG_TYPE_LANDLOCK_FILE_OPEN, BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION
and BPF_PROG_TYPE_LANDLOCK_MMAP_FILE as described in "[RFC v2 06/10]
landlock: Add LSM hooks".

I tried to split the commits as much as possible to ease the review. The
"[RFC v2 10/10] samples/landlock: Add sandbox example" may help to see
the whole picture.

Hope this helps,
 Micka=C3=ABl


--2HflmeHHgbTbeHlc69LqQTKE1mnqnoMgi--

--Al6xw5FI9qr3UgJ4HsDw4rRlN4Qqoc78t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXvvlJAAoJECLe/t9zvWqV83YH+wYlHNVILLbD3w04O+3pZxln
oyE29E0ZzxCPSsNIFhReeRhKh9p7vKQgjRj+J+0l17TB2hPGQ4l/vxEUeM816NQ0
3/1UoX80s+CVKfRObYygcegDA07Db3WUQ871xlfGm8+Q1eC+KfYvxGA/L0Yb/8pT
E4WcII4ymy/pFcnPUo086nq+1lh9kdtfx3YZVgTRwgsILQ/K1wEbZ69EL1NmgZed
L2El51io05Q2DxwWFbC0pxsFruBoveMkKZLo/YARKrPnxP5/couxIi7mJg5lvKCR
qdzDeEIwUHzrriL7/1S2DtaU+jBdPfcoPLvHEdaPBeaQCQahbaZPl49tG9WyyuE=
=UfDs
-----END PGP SIGNATURE-----

--Al6xw5FI9qr3UgJ4HsDw4rRlN4Qqoc78t--
