From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 01/17] shm-signal: shared-memory signals
Date: Wed, 01 Apr 2009 08:12:27 -0400
Message-ID: <49D35A2B.10907@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184252.28333.70623.stgit@dev.haskins.net> <49D280C0.8010802@redhat.com> <49D283F7.7030508@novell.com> <49D285AE.7030604@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4A1F5671234A25D4B0882368"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D285AE.7030604@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4A1F5671234A25D4B0882368
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>>> +struct shm_signal_irq {
>>>> +    __u8                  enabled;
>>>> +    __u8                  pending;
>>>> +    __u8                  dirty;
>>>> +};
>>>>        =20
>>> Some ABIs may choose to pad this, suggest explicit padding.
>>>    =20
>>
>> Yeah, good idea.  What is the official way to do this these days?  Are=

>> GCC pragmas allowed?
>>
>>  =20
>
> I just add a __u8 pad[5] in such cases.

Oh, duh.  Dumb question.  I was getting confused with "pack", not pad.  :=
)

>
>>>> +
>>>> +struct shm_signal;
>>>> +
>>>> +struct shm_signal_ops {
>>>> +    int      (*inject)(struct shm_signal *s);
>>>> +    void     (*fault)(struct shm_signal *s, const char *fmt, ...);
>>>>        =20
>>> Eww.  Must we involve strings and printf formats?
>>>    =20
>>
>> This is still somewhat of a immature part of the design.  Its supposed=

>> to be used so that by default, its a panic.  But on the host side, we
>> can do something like inject a machine-check.  That way malicious/brok=
en
>> guests cannot (should not? ;) be able to take down the host.  Note tod=
ay
>> I do not map this to anything other than the default panic, so this
>> needs some love.
>>
>> But given the asynchronous nature of the fault, I want to be sure we
>> have decent accounting to avoid bug reports like "silent MCE kills the=

>> guest" ;)  At least this way, we can log the fault string somewhere to=

>> get a clue.
>>  =20
>
> I see.
>
> This raises a point I've been thinking of - the symmetrical nature of
> the API vs the assymetrical nature of guest/host or user/kernel
> interfaces.  This is most pronounced in ->inject(); in the host->guest
> direction this is async (host can continue processing while the guest
> is handling the interrupt), whereas in the guest->host direction it is
> synchronous (the guest is blocked while the host is processing the
> call, unless the host explicitly hands off work to a different thread).=


Note that this is exactly what I do (though it is device specific).=20
venet-tap has a ioq_notifier registered on its "rx" ring (which is the
tx-ring for the guest) that simply calls ioq_notify_disable() (which
calls shm_signal_disable() under the covers) and it wakes its
rx-thread.  This all happens in the context of the hypercall, which then
returns and allows the vcpu to re-enter guest mode immediately.


>
>



--------------enig4A1F5671234A25D4B0882368
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTWisACgkQlOSOBdgZUxmSkwCggtjW6BuiU2b3xEX5kM4vtg37
asAAn3RVjDpG4fAkFQNtN79N2VDxlnAG
=XTuS
-----END PGP SIGNATURE-----

--------------enig4A1F5671234A25D4B0882368--
