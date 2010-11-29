From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 22:35:25 +0200
Message-ID: <4CF40E8D.1010506@iki.fi>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>	<4CF3EBF2.5060308@iki.fi>	<AANLkTinQ1qbp9SyWgw7TdvH=5x_1AA6zqLkaa7c4PBGQ@mail.gmail.com>	<4CF3FE85.6040406@iki.fi> <AANLkTimfUFuJKMwp6X65z_NRE4pPKy-6_fEu19Gaqycm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:60935 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab0K2Uf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 15:35:28 -0500
Received: by ewy5 with SMTP id 5so2292242ewy.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 12:35:27 -0800 (PST)
In-Reply-To: <AANLkTimfUFuJKMwp6X65z_NRE4pPKy-6_fEu19Gaqycm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2010 10:09 PM, David Shwatrz wrote:
> Timo,
> Thanks for your answer.
> 
>> Alternatively the other RFCs say that the checksum can be just
>> recalculated. That's what the linux stack does: it throws the old
>> checksum away (ignored on local receive and recalculated on send
>> forward paths).
> 
> Sorry, something here seems to me still wrong; maybe I miss something.
> We are talking about transport mode. Let's take TCP for example.
> the packet is received by another peer. It is on port 4500 because of
> NAT-T. Since it is ESP encrypted , it is it is decrypted. It reaches
> the TCP layer. In TCP (as opposed to UDP), the checksum is mandatory.
> But the checksum in that TCP header of the received
> packet will not be correct, since the IP header of that packet is
> **NOT** the original address ; the IP address was changed by the NAT.
> The NAT  cannot change the TCP checksum since it is encrypted. So
> wouldn't we have a checksum error in the case of TCP ?  It seems to me
> that the purpose of NAT-OA was to pass the
> original address, so that there will be no error in such a case.
> But again, maybe I miss something, since I did not heard that
> transport mode has any problems with NAT-T. Or maybe this was not
> tested?

Yes, it's the primary use case for NAT-OA, to allow "fast" update of the
checksum.

The Linux way works too. It's tested.

Like I said, the IPsec stack says to TCP/UDP stack part "I've already
check the checksum, do not look at it". If the packet is forwarded the
kernel (or NIC hardware) *recalculates* the proper checksum; as if it
was generating the packet in first place.

Using NAT-OA to update checksum is purely an optimisation; mostly useful
only when forwarding form one IPsec tunnel to another one which does not
happen often in transport mode (perhaps only in some very special NAT
setups).
