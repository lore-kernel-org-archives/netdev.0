From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Thu, 15 Sep 2016 00:11:49 +0200
Message-ID: <57D9CB25.1010103@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lKO74CA2sD0XCTUj2vFvWVHClJOn6KPVV"
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
Return-path: <kernel-hardening-return-4636-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lKO74CA2sD0XCTUj2vFvWVHClJOn6KPVV
Content-Type: multipart/mixed; boundary="h0i5Tiho5jhQa6e43DaduaK6qDfkgMPKC";
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
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Message-ID: <57D9CB25.1010103@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
In-Reply-To: <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>

--h0i5Tiho5jhQa6e43DaduaK6qDfkgMPKC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 20:27, Andy Lutomirski wrote:
> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>> Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initial=
ly
>> set for all cgroup except the root. The flag is clear when a new proce=
ss
>> without the no_new_privs flags is attached to the cgroup.
>>
>> If a cgroup is landlocked, then any new attempt, from an unprivileged
>> process, to attach a process without no_new_privs to this cgroup will
>> be denied.
>=20
> Until and unless everyone can agree on a way to properly namespace,
> delegate, etc cgroups, I think that trying to add unprivileged
> semantics to cgroups is nuts.  Given the big thread about cgroup v2,
> no-internal-tasks, etc, I just don't see how this approach can be
> viable.

As far as I can tell, the no_new_privs flag of at task is not related to
namespaces. The CGRP_NO_NEW_PRIVS flag is only a cache to quickly access
the no_new_privs property of *tasks* in a cgroup. The semantic is unchang=
ed.

Using cgroup is optional, any task could use the seccomp-based
landlocking instead. However, for those that want/need to manage a
security policy in a more dynamic way, using cgroups may make sense.

I though cgroup delegation was OK in the v2, isn't it the case? Do you
have some links?

>=20
> Can we try to make landlock work completely independently of cgroups
> so that it doesn't get stuck and so that programs can use it without
> worrying about cgroup v1 vs v2, interactions with cgroup managers,
> cgroup managers that (supposedly?) will start migrating processes
> around piecemeal and almost certainly blowing up landlock in the
> process, etc?

This RFC handle both cgroup and seccomp approaches in a similar way. I
don't see why building on top of cgroup v2 is a problem. Is there
security issues with delegation?

>=20
> I have no problem with looking at prototypes for how landlock +
> cgroups would work, but I can't imagine the result being mergeable.
>=20


--h0i5Tiho5jhQa6e43DaduaK6qDfkgMPKC--

--lKO74CA2sD0XCTUj2vFvWVHClJOn6KPVV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2cslAAoJECLe/t9zvWqVj64IAI/+y5aONgOczHHPyTrbK0vE
+XlLgZTxyvxhuPNGpFwANj8F/sp1YDmzUxtqkgcLUoGjjQ8FZ/47xxr5JpfJbC1v
AMhUajW+adtCq/fzwQ1/MswyuhNURjEEPK0E8XCmub8aPVWHi8vnRbYswFjsWLHh
BNjLVyVYI2gyTea+luJ/xstp2vXRhDNNejBs/f4BvuG/Q/sav8B5Ra6U2egejrkX
rEa7qf+NbS53RDFtpiJvW3dsu9JM/NYQrcGEdasstBOyBG8CEsgFIHwKxi1PAdev
rfTCZoD90eTfz7nJ8lxt1DdVTk4v5/DB2F2YO2W1QSNGOWBCHpD6lAr37uj2ELI=
=nVk/
-----END PGP SIGNATURE-----

--lKO74CA2sD0XCTUj2vFvWVHClJOn6KPVV--
