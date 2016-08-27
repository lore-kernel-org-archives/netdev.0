From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing (cgroup
 delegation)
Date: Sat, 27 Aug 2016 17:21:39 +0200
Message-ID: <57C1B003.1030608@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
 <57C1AD75.8070304@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="wlr55cMgIdPiSJFX8c2whrsfJDpufv9Dx"
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
        Network Development <netdev@vger.kernel.org>,
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4487-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <57C1AD75.8070304@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wlr55cMgIdPiSJFX8c2whrsfJDpufv9Dx
Content-Type: multipart/mixed; boundary="MhbNrtlcmVXLMqSMdAXQF4iB0tlla5RTo"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
 Andy Lutomirski <luto@amacapital.net>
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
 Network Development <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
 cgroups@vger.kernel.org
Message-ID: <57C1B003.1030608@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing (cgroup
 delegation)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWhzk4ukY7-Ynr5Hb9wHGTpcHUe2TvkVRxgvoU0-esDAA@mail.gmail.com>
 <57C1AD75.8070304@digikod.net>
In-Reply-To: <57C1AD75.8070304@digikod.net>

--MhbNrtlcmVXLMqSMdAXQF4iB0tlla5RTo
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Cc Tejun and the cgroups ML.

On 27/08/2016 17:10, Micka=C3=ABl Sala=C3=BCn wrote:
> On 27/08/2016 09:40, Andy Lutomirski wrote:
>> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>>
>>> # Sandbox example with conditional access control depending on cgroup=

>>>
>>>   $ mkdir /sys/fs/cgroup/sandboxed
>>>   $ ls /home
>>>   user1
>>>   $ LANDLOCK_CGROUPS=3D'/sys/fs/cgroup/sandboxed' \
>>>       LANDLOCK_ALLOWED=3D'/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
>>>       ./sandbox /bin/sh -i
>>>   $ ls /home
>>>   user1
>>>   $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
>>>   $ ls /home
>>>   ls: cannot open directory '/home': Permission denied
>>>
>>
>> Something occurs to me that isn't strictly relevant to landlock but
>> may be relevant to unprivileged cgroups: can you cause trouble by
>> setting up a nastily-configured cgroup and running a setuid program in=

>> it?
>>
>=20
> I hope not=E2=80=A6 But the use of cgroups should not be mandatory for =
Landlock.
>=20

In a previous email:

On 26/08/2016 17:50, Tejun Heo wrote:
> I haven't looked in detail but in general I'm not too excited about
> layering security mechanism on top of cgroup.  Maybe it makes some
> sense when security domain coincides with resource domains but at any
> rate please keep me in the loop.



--MhbNrtlcmVXLMqSMdAXQF4iB0tlla5RTo--

--wlr55cMgIdPiSJFX8c2whrsfJDpufv9Dx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwbADAAoJECLe/t9zvWqVi4oH/jzG6vKptGRk0LdxW1QVQEKw
5klMt/IqVP14wvyIWnjZrCY6AuYpHogp9tRYtwWIlq9hcbqyMGtkZjGMlZn9eR+l
q7WoSgzcdP0+cD7o2cbLQSn+KRilygz77Cl5WDxC4XmN+3tsTKUtzdPrkm/HJ319
i+O2oMpoK88PC9ZI2ObUd+QdoC8Fzb3LT88VrA+3z66DOmHTi1HwEQyy2uiV/4Vs
dPbx8u+Fsvm2ZFyyjYoT7s/23PGoue5pvFacHBlKvWLTP0OvSe4zc3JFk/j7UbBW
fyWNx5yNxaTr+96JOTVpwAvRw8+zqlsIBofEkN2LHD3/zshzoEkr9dlXEbtK4GA=
=amZy
-----END PGP SIGNATURE-----

--wlr55cMgIdPiSJFX8c2whrsfJDpufv9Dx--
