From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
Date: Thu, 15 Sep 2016 00:34:20 +0200
Message-ID: <57D9D06C.2020007@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-12-mic@digikod.net>
 <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HkK2Hagt747JdCiFGBt2gCQ3Ep3q38USg"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4638-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HkK2Hagt747JdCiFGBt2gCQ3Ep3q38USg
Content-Type: multipart/mixed; boundary="Txd8a9wRdcl5jUFMcA00VdHwC6uwISSRi";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <57D9D06C.2020007@digikod.net>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-12-mic@digikod.net>
 <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
In-Reply-To: <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>

--Txd8a9wRdcl5jUFMcA00VdHwC6uwISSRi
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 20:43, Andy Lutomirski wrote:
> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>> A Landlock program will be triggered according to its subtype/origin
>> bitfield. The LANDLOCK_FLAG_ORIGIN_SECCOMP value will trigger the
>> Landlock program when a seccomp filter will return RET_LANDLOCK.
>> Moreover, it is possible to return a 16-bit cookie which will be
>> readable by the Landlock programs in its context.
>=20
> Are you envisioning that the filters will return RET_LANDLOCK most of
> the time or rarely?  If it's most of the time, then maybe this could
> be simplified a bit by unconditionally calling the landlock filter and
> letting the landlock filter access a struct seccomp_data if needed.

Exposing seccomp_data in a Landlock context may be a good idea. The main
implication is that Landlock programs may then be architecture specific
(if dealing with data) as seccomp filters are. Another point is that it
remove any direct binding between seccomp filters and Landlock programs.
I will try this (more simple) approach.

>=20
>>
>> Only seccomp filters loaded from the same thread and before a Landlock=

>> program can trigger it through LANDLOCK_FLAG_ORIGIN_SECCOMP. Multiple
>> Landlock programs can be triggered by one or more seccomp filters. Thi=
s
>> way, each RET_LANDLOCK (with specific cookie) will trigger all the
>> allowed Landlock programs once.
>=20
> This interface seems somewhat awkward.  Should we not have a way to
> atomicaly install a whole pile of landlock filters and associated
> seccomp filter all at once?

I can change the seccomp(2) use in this way: instead of loading a
Landlock program, (atomically) load an array of Landlock programs.

However, exposing seccomp_data to Landlock programs looks like a better
way to deal with it. This does not needs to manage an array of Landlock
programs.

 Micka=C3=ABl


--Txd8a9wRdcl5jUFMcA00VdHwC6uwISSRi--

--HkK2Hagt747JdCiFGBt2gCQ3Ep3q38USg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2dBsAAoJECLe/t9zvWqVBycIAJZFEnAjvsq6QOBLqfqCdKa8
EcmGGeJ1ZN/hzJpPpLLn1O/YXrRsr2fuGQAsueR5CYbXCM+BCqnDEnuuWUZllre4
5SnE3nV+kS0FvsInbE2PSmati7kNA76KeG1wwX5bUJcgI9ZUrE+jNZT4XBkcs57N
b8MtQoJkvQ0RGVlitBbg9MGUifM/VP85LRG3IHr1ln5KGKcrTF/wAeWDDvhtVxo3
V+WyhMuN/p5te4At+nr/E4wPuDyhfz+8wPSuHQ/5ra/NKDPADf+9FCpa76QC7QkB
0zq4CDFS0Uw/HAMgkwmUgaCX2WYe8yLGrUrFBPwUmJ+pQiHTByG+1KmEnwsWg3U=
=U+su
-----END PGP SIGNATURE-----

--HkK2Hagt747JdCiFGBt2gCQ3Ep3q38USg--
