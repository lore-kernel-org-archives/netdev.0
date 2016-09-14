From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 21/22] bpf,landlock: Add optional skb pointer in the
 Landlock context
Date: Thu, 15 Sep 2016 00:46:41 +0200
Message-ID: <57D9D351.3010902@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-22-mic@digikod.net>
 <20160914212054.GC57174@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="irtHQVAR54SKacq3shF7nK0B90UPfEteX"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
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
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.ker
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4640-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914212054.GC57174@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--irtHQVAR54SKacq3shF7nK0B90UPfEteX
Content-Type: multipart/mixed; boundary="4DGskshHj2iW7oitue0fQkAW83HPNM979";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57D9D351.3010902@digikod.net>
Subject: Re: [RFC v3 21/22] bpf,landlock: Add optional skb pointer in the
 Landlock context
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-22-mic@digikod.net>
 <20160914212054.GC57174@ast-mbp.thefacebook.com>
In-Reply-To: <20160914212054.GC57174@ast-mbp.thefacebook.com>

--4DGskshHj2iW7oitue0fQkAW83HPNM979
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 23:20, Alexei Starovoitov wrote:
> On Wed, Sep 14, 2016 at 09:24:14AM +0200, Micka=EBl Sala=FCn wrote:
>> This is a proof of concept to expose optional values that could depend=

>> of the process access rights.
>>
>> There is two dedicated flags: LANDLOCK_FLAG_ACCESS_SKB_READ and
>> LANDLOCK_FLAG_ACCESS_SKB_WRITE. Each of them can be activated to acces=
s
>> eBPF functions manipulating a skb in a read or write way.
>>
>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
> ...
>>  /* Handle check flags */
>>  #define LANDLOCK_FLAG_FS_DENTRY		(1 << 0)
>> @@ -619,12 +621,15 @@ struct landlock_handle {
>>   * @args: LSM hook arguments, see include/linux/lsm_hooks.h for there=

>>   *        description and the LANDLOCK_HOOK* definitions from
>>   *        security/landlock/lsm.c for their types.
>> + * @opt_skb: optional skb pointer, accessible with the
>> + *           LANDLOCK_FLAG_ACCESS_SKB_* flags for network-related hoo=
ks.
>>   */
>>  struct landlock_data {
>>  	__u32 hook; /* enum landlock_hook_id */
>>  	__u16 origin; /* LANDLOCK_FLAG_ORIGIN_* */
>>  	__u16 cookie; /* seccomp RET_LANDLOCK */
>>  	__u64 args[6];
>> +	__u64 opt_skb;
>>  };
>=20
> missing something here.
> This patch doesn't make use of it.
> That's something for the future?
> How that field will be populated?
> Why make it different vs the rest or args[6] ?
>=20
>=20

I don't use this code, it's only purpose is to show how to deal with
fine-grained privileges of Landlock programs (to allow Sargun to add his
custom helpers from Checmate). However, this optional field may be part
of args[6].


--4DGskshHj2iW7oitue0fQkAW83HPNM979--

--irtHQVAR54SKacq3shF7nK0B90UPfEteX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2dNRAAoJECLe/t9zvWqVJOYIAJtOFHp7H8Fr+W9UKwNuyItw
7/iKyjX2oEfJCRdx6enyUubotPpMzO/IH0phb9/n+ou1mT8gyWZ5grqMip7DZEZQ
Z+d5TjhoGWyQ0RjETrEIaXYSOB+DFxUGq5x7HaXo30WX5vV+q1Nd9uWOJIvOWwme
6uHFwBm1+cBG2KQppVFC8bAqBAydfRKw7ZfPeJYizSz0oYYpmst96RCokE3DSEtl
FVx52oHwMoz0g3FYPyzhM33EGcK/BKIHdJMyO2OCVEU8wGzb0DOX4YLsOr5xD0xK
iLZAHs9NQHrnVL22Z85Yr1h1Du0rC8ffrQwTyIkpLgTEMsHU4hv/uaj8Z9e7frk=
=tlHJ
-----END PGP SIGNATURE-----

--irtHQVAR54SKacq3shF7nK0B90UPfEteX--
