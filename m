From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 10:18:37 +0100
Message-ID: <4B7D05ED.4060900@simula.no>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net> <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi> <4B7CFDE4.4010003@simula.no> <4B7D01CE.1030101@lastsummer.de> <alpine.DEB.2.00.1002181102260.9961@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Franco Fichtner <franco@lastsummer.de>,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:59639 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530Ab0BRJSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 04:18:45 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Ni2Wx-0003GJ-Pz
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 10:18:43 +0100
In-Reply-To: <alpine.DEB.2.00.1002181102260.9961@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2010 10:09 AM, Ilpo J=E4rvinen wrote:
> On Thu, 18 Feb 2010, Franco Fichtner wrote:
>=20
>> Andreas Petlund wrote:
>>> On 02/18/2010 09:41 AM, Ilpo J=E4rvinen wrote:
>>>  =20
>>>> On Wed, 17 Feb 2010, David Miller wrote:
>>>>
>>>>    =20
>>>>> From: Andreas Petlund <apetlund@simula.no>
>>>>> Date: Tue, 16 Feb 2010 15:40:41 +0100
>>>>>
>>>>>      =20
>>>>>> @@ -341,6 +342,8 @@ struct tcp_sock {
>>>>>>  	u16	advmss;		/* Advertised MSS
>>>>>> */
>>>>>>  	u8	frto_counter;	/* Number of new acks after RTO */
>>>>>>  	u8	nonagle;	/* Disable Nagle algorithm?
>>>>>> */
>>>>>> +	u8      thin_lto    : 1,/* Use linear timeouts for thin
>>>>>> streams */
>>>>>> +		thin_undef  : 7;
>>>>>>         =20
>>>>> There is now a gap of 3 unused bytes here in this critical
>>>>> core TCP socket data structure.
>>>>>
>>>>> Please either find a way to avoid this hole, or document
>>>>> it with a comment.
>>>>>      =20
>>>> There would be multiple bits free for use in both frto_counter and=
 nonagle
>>>> byte.
>>>>
>>>>    =20
>>>
>>> I was playing aroud with this setup:
>>>
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> u8	nonagle     : 4,/* Disable Nagle algorithm?             */
>>> 	thin_lto    : 1,/* Use linear timeouts for thin streams */
>>> 	thin_dupack : 1,/* Fast retransmit on first dupack      */
>>> 	thin_undef  : 2;
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>
>>> Do you think that would do the trick?
>>>  =20
>>
>> According to Ilpo, it would be ok to reduce both ftro_counter and
>> nonagle, so why not join all these into u16 and leave the remaining
>> free bits documented for other people. Like this:
>>
>>    u16 frto_counter:x; /* Number of new acks after RTO */
>>    u16 nonagle:y; /* Disable Nagle algorithm? */
>>    u16 thin_lto:1; /* Use linear timeouts for thin streams */
>>    u16 unused:15-x-y;
>>
>> Not sure about the y and x. Ilpo, can you comment on those values?
>=20
> I don't remember top of the hat how much of nonagle used, but for=20
> frto_counter max value was 3 iirc.=20

I think nonagle uses 4 bits:
=3D=3D=3D=3D=3D=3D
#define TCP_NAGLE_OFF           1       /* Nagle's algo is disabled */
#define TCP_NAGLE_CORK          2       /* Socket is corked         */
#define TCP_NAGLE_PUSH          4       /* Cork is overridden for alrea=
dy queued data */
=3D=3D=3D=3D=3D=3D

> However, I'm unsure if compiler is=20
> nowadays wise enough to handle bitfields in some not all so stupid wa=
y.

Would you then recommend to use a byte for each value, thus avoiding th=
e bitfields?

Cheers,
Andreas

