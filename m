From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 06/22] landlock: Add LSM hooks
Date: Thu, 20 Oct 2016 00:42:34 +0200
Message-ID: <5807F6DA.1090807@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-7-mic@digikod.net>
 <20161019151906.GC22003@pox.localdomain>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="RIxjbA0OLHDrI3OErWHHuNObMiMcqC5oj"
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <kernel-hardening-return-4952-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161019151906.GC22003@pox.localdomain>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RIxjbA0OLHDrI3OErWHHuNObMiMcqC5oj
Content-Type: multipart/mixed; boundary="CA7XFcoWrm6LRSTSGSLRBnGFvQu4sfc0k";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Thomas Graf <tgraf@suug.ch>
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
Message-ID: <5807F6DA.1090807@digikod.net>
Subject: Re: [RFC v3 06/22] landlock: Add LSM hooks
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-7-mic@digikod.net>
 <20161019151906.GC22003@pox.localdomain>
In-Reply-To: <20161019151906.GC22003@pox.localdomain>

--CA7XFcoWrm6LRSTSGSLRBnGFvQu4sfc0k
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 19/10/2016 17:19, Thomas Graf wrote:
> On 09/14/16 at 09:23am, Micka=EBl Sala=FCn wrote:
>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index 9aa01d9d3d80..36c3e482239c 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -85,6 +85,8 @@ enum bpf_arg_type {
>> =20
>>  	ARG_PTR_TO_CTX,		/* pointer to context */
>>  	ARG_ANYTHING,		/* any (initialized) argument is ok */
>> +
>> +	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
>=20
> This should go into patch 7 I guess?

Right, the ARG_PTR_* are only used by BPF helpers.

>=20
>> +void __init landlock_add_hooks(void)
>> +{
>> +	pr_info("landlock: Becoming ready for sandboxing\n");
>> +	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
>> +}
>=20
> Can we add the hooks when we load the first BPF program for a hook? Tha=
t
> would also allow to not make this conditional on a new config option
> which all all distros have to enable anyway.

We could either add hook by hook or all hooks at once when loading a BPF
program for which its subtype match the hook type, but I'm not sure it
is worth it.

I'd like to enable this LSM by default but we should be able to disable
it if needed, like most kernel features.

>=20
> I would really like to see this patch split into the LSM part which
> allows running BPF progs at LSM and your specific sandboxing use case
> which requires the new BPF helpers, new reg type, etc.
>=20

I'll try to split it as much as possible.


--CA7XFcoWrm6LRSTSGSLRBnGFvQu4sfc0k--

--RIxjbA0OLHDrI3OErWHHuNObMiMcqC5oj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYB/baAAoJECLe/t9zvWqVYYkH/1oSGtjxwvJ2odiESyJuok6F
O1nNK2CoGlkqX1aUVq8hDyxPOCm3zwF2N0bYJCjHlwdaohF7EiBZcUi1MBf3AkrO
q8+UFjaRnpQQSU8ZKOLffLhycCXc0aL+8rSjFiEDPQvFzqzU/lrdyptjvl+Yj3Lz
UgvxLqaB5F6M+dBMEg41Dcxv32KX61HvhvkZFMQt3oErt3i7H9ca4m7ivJ8AMmmh
Y46ViLKce7qu7SJEtAB7VuGrmVG+Y6apJpYGSbZG90rU/laiw/fnKvG/O2Pio9Yk
w3Cm2aAdaqsWu4WtpKvffKt7K4+1H8Q0VOOR8BwzKNPfwiiBxFp+b/Yw2glACKo=
=BE99
-----END PGP SIGNATURE-----

--RIxjbA0OLHDrI3OErWHHuNObMiMcqC5oj--
