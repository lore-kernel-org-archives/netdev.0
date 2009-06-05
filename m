From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Fri, 05 Jun 2009 10:44:40 -0400
Message-ID: <4A292F58.8000004@gmail.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <200906051425.02924.rusty@rustcorp.com.au> <4A290800.1030803@novell.com> <200906060005.47127.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig613E9ADC2888CA652BFC921F"
Cc: Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200906060005.47127.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig613E9ADC2888CA652BFC921F
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Rusty Russell wrote:
> On Fri, 5 Jun 2009 09:26:48 pm Gregory Haskins wrote:
>  =20
>> Hi Rusty,
>>
>> Rusty Russell wrote:
>>    =20
>>> On Fri, 5 Jun 2009 04:19:17 am Gregory Haskins wrote:
>>>      =20
>>>> Avi Kivity wrote:
>>>>        =20
>>>>> Gregory Haskins wrote:
>>>>> One idea is similar to signalfd() or eventfd()
>>>>>          =20
>>>> And thus the "kvm-eventfd" (irqfd/iosignalfd) interface project was
>>>> born. ;)
>>>>        =20
>>> The lguest patch queue already has such an interface :)
>>>      =20
>> Cool!  Ultimately I think it will be easier if both lguest+kvm support=

>> the same eventfd notion so this is good you are already moving in the
>> same direction.
>>    =20
>
> Not really; lguest doesn't do PCI.
>  =20

Thats ok.  I see these eventfd interfaces as somewhat orthogonal to
PCI.  I.e. if both lguest and kvm have an eventfd mechnism for signaling
in both directions (e.g. interrupts and io), it would make it easier to
support the kind of thing I am striving for with a unified backend.=20
That is: one in-kernel virtio-net that works in both (or even many) HV
environments.  I see that as a higher layer abstraction than PCI, per se.=

>  =20
>>> And I have a partially complete in-kernel virtio_pci patch with the s=
ame
>>> trick.
>>>      =20
>> I thought lguest didn't use pci?  Or do you just mean that you have an=

>> in-kernel virtio-net for lguest?
>>    =20
>
> No, this was for kvm.  Sorry for the confusion.
>  =20

Ah, sorry.  Well, if its in any kind of shape to see the light of day,
please forward it over.  Perhaps Michael and I can craft it into a
working solution.

>  =20
>> Other than the potential rcu issues that Paul already addressed, looks=

>> good.  FWIW: this looks like what we are calling "iosignalfd" on the k=
vm
>> land (unless I am misunderstanding).  Do you have the equivalent of
>> "irqfd" going the other way?
>>    =20
>
> Yes; lguest uses write() (offset indicates cpu #) rather than ioctls, b=
ut=20
> anyone can do the LHREQ_IRQ write to queue an interrupt for delivery.
>
> So the threads just get the same /dev/lguest fd and it's simple.
>  =20

Ah, ok.  Thats workable, too.  (This kind of detail would be buried in
the "lguest connector" for vbus anyway, so it doesn't have to have a
uniform "eventfd_signal()" interface to work.  The fd concept alone is
sufficiently flexible).

Thanks Rusty,
-Greg


--------------enig613E9ADC2888CA652BFC921F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkopL1wACgkQP5K2CMvXmqGArgCfTWuAeOAwrZwOMVFHlcEpZ5Qt
epQAniYsSgpVSW1eYMx7q+0kgxkI9iTq
=XsO4
-----END PGP SIGNATURE-----

--------------enig613E9ADC2888CA652BFC921F--
