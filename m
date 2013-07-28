From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1 net] net: fec: workaround stop tx during errata
 ERR006358
Date: Sat, 27 Jul 2013 20:15:18 -0700 (PDT)
Message-ID: <20130727.201518.1008971678857409156.davem@davemloft.net>
References: <1374732353-6505-1-git-send-email-Frank.Li@freescale.com>
	<9848F2DB572E5649BA045B288BE08FBE015BE134@039-SN2MPN1-021.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B20596@freescale.com, shawn.guo@linaro.org, netdev@vger.kernel.org,
	l.stach@pengutronix.de, r.schwebel@pengutronix.de, lznuaa@gmail.com
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab3G1DPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 23:15:19 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015BE134@039-SN2MPN1-021.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Fugang-B38611 <B38611@freescale.com>
Date: Thu, 25 Jul 2013 08:16:23 +0000

> On 25/07/13 14:06, Li Frank wrote:
>>If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously detected as not set during a prior frame transmission, then the ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in frames not being transmitted until there is a 0-to-1 transition on ENET_TDAR[TDAR].
>>
>>Workarounds:
>>code can use the transmit frame interrupt flag (ENET_EIR[TXF]) as a method to detect whether the ENET has completed transmission and the ENET_TDAR[TDAR] has been cleared. If ENET_TDAR[TDAR] is detected as cleared when packets are queued and waiting for transmit, then a write to the TDAR bit will restart TxBD processing.
>>
>>This case main happen when loading is light. A ethernet package may not send out utile next package put into tx queue.
>>
>>How to test:
>>while [ true ]
>>do
>>	ping <IP> -s 10000 -w 4
>>	ping <IP> -s 6000 -w 2
>>	ping <IP> -s 4000 -w 2
>>	ping <IP> -s 10000 -w 2
>>done
>>
>>You will see below result in overnight test.
>>
>>6008 bytes from 10.192.242.116: seq=1 ttl=128 time=0.722 ms
>>4008 bytes from 10.192.242.116: seq=0 ttl=128 time=1001.008 ms
>>4008 bytes from 10.192.242.116: seq=1 ttl=128 time=1.010 ms
>>10008 bytes from 10.192.242.116: seq=0 ttl=128 time=0.896 ms
>>
>>After apply this patch, >1000ms delay disappear.
>>
>>Signed-off-by: Frank Li <Frank.Li@freescale.com>
> 
> Acked-by: Fugang Duan  <B38611@freescale.com>

Applied, thanks.
