From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v5] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 29 Oct 2013 21:36:59 +0100
Message-ID: <52701C6B.6010900@xdin.com>
References: <5267F4BD.70409@xdin.com> <1382547142.22433.18.camel@joe-AO722> <526AB665.5020402@xdin.com> <1382725918.2425.2.camel@joe-AO722> <AE90C24D6B3A694183C094C60CF0A2F6026B73B9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	<balferreira@googlemail.com>,
	=?windows-1252?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:64845 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775Ab3J2UhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 16:37:04 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73B9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-28 10:17, David Laight wrote:
>> Subject: Re: [PATCH v5] net/hsr: Add support for the High-availabili=
ty Seamless Redundancy protocol
>> (HSRv0)
>>
>> On Fri, 2013-10-25 at 20:20 +0200, Arvid Brodin wrote:
>>> On 2013-10-23 18:52, Joe Perches wrote:
>>>> On Wed, 2013-10-23 at 18:09 +0200, Arvid Brodin wrote:
>> []
>>>>> +/* above(a, b) - return 1 if a > b, 0 otherwise.
>>>>> + */
>>>>> +static bool above(u16 a, u16 b)
>>>>> +{
>>>>> +	/* Remove inconsistency where above(a, b) =3D=3D below(a, b) */
>>>>> +	if ((int) b - a =3D=3D 32768)
>>>>> +		return 0;
>>>>> +
>>>>> +	return (((s16) (b - a)) < 0);
>>>>> +}
>>>>> +#define below(a, b)		above((b), (a))
>>>>> +#define above_or_eq(a, b)	(!below((a), (b)))
>>>>> +#define below_or_eq(a, b)	(!above((a), (b)))
>>>>
>>>> This looks odd.
>>>
>>> It relies on unsigned arithmetic to compare two values that may wra=
p. I.e.,
>>> it doesn't care about the absolute sizes, but only about the distan=
ce
>>> between the numbers.
>=20
> I'd have thought it wasn't really worth worrying about what happens
> when a ^ b =3D=3D 0x8000. Anything using modulo 16 distances shouldn'=
t
> really see such values.
> Perhaps just document the effect.

Unfortunately there are circumstances where such values can be seen -=20
specifically when there is a network problem. And since HSR is meant to
be a high-availability protocol, it is imperative that such cases are=20
handled consistently. (That would have been the case with modulo 32 as
well, even if the occations when it happened would be a lot rarer, and
the resulting bugs would be much harder to find.)

>=20
> Also, if these definitions are in a .h file they need better names

They're in a .c file, but between your's and Joe Perches' comments, I c=
an
see that the names and description needs a face-lift.

Thanks for looking at the code!

>=20
> 	David
>=20

--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
