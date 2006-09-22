From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Fri, 22 Sep 2006 11:15:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609221112000.7628@d.namei>
References: <20060922112948.GA17335@2ka.mipt.ru> <20060922121920.GA3172@2ka.mipt.ru>
 <4513D5B5.6090301@trash.net> <20060922140318.GA14408@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:54951 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932584AbWIVPPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 11:15:37 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060922140318.GA14408@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006, Evgeniy Polyakov wrote:

> 17:45:04.770225 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x070635c0,seq=0x1), length 84
> 17:45:04.770344 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x01f452be,seq=0x2), length 84
> 17:45:04.777560 IP 192.168.4.79.ssh > 192.168.4.78.56527: P 3412388275:3412388295(20) ack 1965868757 win 91 <nop,nop,timestamp 1531076218 4294904370>

Where are you running tcpdump?  It is normal to see both the encrypted and 
unencrypted packets if you run it on one of the machines doing ipsec, 
because of the way xfrm stacking works.

> 17:45:04.981642 IP 192.168.4.79.ssh > 192.168.4.78.56527: P 0:20(20) ack 1 win 91 <nop,nop,timestamp 1531076269 4294904370>
> 17:45:05.389666 IP 192.168.4.79.ssh > 192.168.4.78.56527: P 0:20(20) ack 1 win 91 <nop,nop,timestamp 1531076371 4294904370>
> 17:45:06.205721 IP 192.168.4.79.ssh > 192.168.4.78.56527: P 0:20(20) ack 1 win 91 <nop,nop,timestamp 1531076575 4294904370>
> 17:45:07.837827 IP 192.168.4.79.ssh > 192.168.4.78.56527: P 0:20(20) ack 1 win 91 <nop,nop,timestamp 1531076983 4294904370>

Not sure what's going on here.

> The same packet.
> 
> 17:45:11.102066 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x070635c0,seq=0x2), length 100
> 17:45:11.102212 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x01f452be,seq=0x3), length 84
> 17:45:12.098146 IP 192.168.4.79.isakmp > 192.168.4.78.isakmp: isakmp: phase 2/others ? oakley-quick[E]
> 17:45:12.098427 IP 192.168.4.78.isakmp > 192.168.4.79.isakmp: isakmp: phase 2/others ? inf

And why racoon packets are here at this stage.

Can you try this with either a fully manual config (setkey only) or 
openswan?


- James
-- 
James Morris
<jmorris@namei.org>
