From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: pmtu discovery on sa esp
Date: Wed, 13 Jun 2007 15:09:10 +0200
Message-ID: <BAY103-DAV1214938C6821D8818D23CB2180@phx.gbl>
References: <BAY103-DAV17DFF0DD3E0AEE8CCCB1F3B2190@phx.gbl> <466E92E4.4020008@trash.net> <BAY103-DAV16399D5C4B8A85492D8738B2180@phx.gbl> <466FE81A.80907@trash.net>
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s16.bay0.hotmail.com ([65.54.246.88]:7814 "EHLO
	bay0-omc1-s16.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757008AbXFMNJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 09:09:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> Marco Berizzi wrote:
> > Patrick McHardy wrote:
> >
> >>We have some MTU opimiztations in 2.6.22-rc that might be related.
> >>Please check with tcpdump what exactly is happening and whether
> >>the 2.6.22-rc box is sending too large packets.
> >
> >
> > I have done a tcpdump capture on the external
> > interface but I don't see anything strange.
>
>
> Try dumping on loopback as well.

indeed: here is:

14:55:58.848705 IP (tos 0xc0, ttl  64, id 1440, offset 0, flags [none],
proto: ICMP (1), length: 576) linux2.6.22 > linux2.6.22: ICMP
linux2.6.21 unreachable - need to frag (mtu 1500), length 556
 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: ESP (50),
length: 1512) linux2.6.22 > linux2.6.21:
ESP(spi=0x91878312,seq=0x1553f), length 1492[|icmp]

> > (I can send to you the capture if you want/need)
> > I have noticed that the mtu on the aes tunnels
> > now is equal to 1450 byte (with 2.6.21 it was
> > 1428). Let me explain:
> >
> > linux 2.6.22-rc4 ->>-AES tunnel ->>- linux 2.6.21 mtu=1450
> > linux 2.6.21 ->>-AES tunnel ->>- linux 2.6.22-rc4 mtu=1428
> >
> > Now as a collateral effects all the windoze boxes
> > aren't able to exchange large packets: I must
> > upgrade all ipsec gateway to 2.6.22-rc4 (or
> > downgrade this box to 2.6.21 again). Hints?
>
>
> The question is whether 1450 is correct. Could you send me the
> output of "ip x s" (obfuscate keys if you want) and "ip x p"?

I have sent to you (not to the list) the info you
asked me.

> What is the MTU of the underlying device?

1500 byte

> Do the encapsulated
> packets still fit?

No, the will not fit (1512 > 1500)

> BTW, are you just using pluto or the entire openswan patch?

only pluto (no klips).


