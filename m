From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 09:36:48 -0400
Message-ID: <49D4BF70.1060301@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC6D61C5F3BF095EB829F9CB0"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4B8B4.4020003@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC6D61C5F3BF095EB829F9CB0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Avi Kivity wrote:
>> =20
>>> My 'prohibitively expensive' is true only if you exit every packet.
>>>
>>>
>>>    =20
>>
>> Understood, but yet you need to do this if you want something like iSC=
SI
>> READ transactions to have as low-latency as possible.
>>  =20
>
> Dunno, two microseconds is too much?  The wire imposes much more.
>

No, but thats not what we are talking about.  You said signaling on
every packet is prohibitively expensive.  I am saying signaling on every
packet is required for decent latency.  So is it prohibitively expensive
or not?

I think most would agree that adding 2us is not bad, but so far that is
an unproven theory that the IO path in question only adds 2us.   And we
are not just looking at the rate at which we can enter and exit the
guest...we need the whole path...from the PIO kick to the dev_xmit() on
the egress hardware, to the ingress and rx-injection.  This includes any
and all penalties associated with the path, even if they are imposed by
something like the design of tun-tap.

Right now its way way way worse than 2us.  In fact, at my last reading
this was more like 3060us (3125-65).  So shorten that 3125 to 67 (while
maintaining line-rate) and I will be impressed.  Heck, shorten it to
80us and I will be impressed.

-Greg


--------------enigC6D61C5F3BF095EB829F9CB0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUv3AACgkQlOSOBdgZUxmmXQCfcMMtqq+f4ZP5WDwmQB94CDZI
TlUAnjttWnvHOZLgQS8wByMSW7j7YQwP
=HX9p
-----END PGP SIGNATURE-----

--------------enigC6D61C5F3BF095EB829F9CB0--
