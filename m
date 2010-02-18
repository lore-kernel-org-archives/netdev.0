From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 09:44:20 +0100
Message-ID: <4B7CFDE4.4010003@simula.no>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net> <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:32810 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab0BRIo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 03:44:28 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Ni1zm-0000Lr-Ks
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 09:44:26 +0100
In-Reply-To: <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2010 09:41 AM, Ilpo J=E4rvinen wrote:
> On Wed, 17 Feb 2010, David Miller wrote:
>=20
>> From: Andreas Petlund <apetlund@simula.no>
>> Date: Tue, 16 Feb 2010 15:40:41 +0100
>>
>>> @@ -341,6 +342,8 @@ struct tcp_sock {
>>>  	u16	advmss;		/* Advertised MSS			*/
>>>  	u8	frto_counter;	/* Number of new acks after RTO */
>>>  	u8	nonagle;	/* Disable Nagle algorithm?             */
>>> +	u8      thin_lto    : 1,/* Use linear timeouts for thin streams *=
/
>>> +		thin_undef  : 7;
>>> =20
>>
>> There is now a gap of 3 unused bytes here in this critical
>> core TCP socket data structure.
>>
>> Please either find a way to avoid this hole, or document
>> it with a comment.
>=20
> There would be multiple bits free for use in both frto_counter and no=
nagle=20
> byte.
>=20

I was playing aroud with this setup:

=3D=3D=3D=3D=3D=3D=3D=3D=3D
u8	nonagle     : 4,/* Disable Nagle algorithm?             */
	thin_lto    : 1,/* Use linear timeouts for thin streams */
	thin_dupack : 1,/* Fast retransmit on first dupack      */
	thin_undef  : 2;
=3D=3D=3D=3D=3D=3D=3D=3D=3D

Do you think that would do the trick?

Regards,
Andreas
