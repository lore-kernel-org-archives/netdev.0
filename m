From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 17:33:38 -0800
Message-ID: <4B43E872.5000809@hp.com>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>	<20100105.154928.80012641.davem@davemloft.net>	<7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org> <20100105.163343.14826539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dhananjay.phadke@qlogic.com, shemminger@vyatta.com,
	amit.salecha@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:25468 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0AFBdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 20:33:41 -0500
In-Reply-To: <20100105.163343.14826539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
> Date: Tue, 5 Jan 2010 15:55:10 -0800
> 
> 
>>The LRO you are talking about was still kernel based
>>LRO. Even GRO doesn't save PCIe transactions as much
>>HW LRO does. That is the key. The difference between
>>HW LRO and GRO is significant to keep former alive
>>for a while.

Is it really the PCIe transactions (*)?  ISTR that HW LRO also tended to 
significantly cut-down on the ACK rate, rather like the oft-derided ACK 
avoidance heuristics in Solaris, HP-UX and various MacOSX revs.

rick jones

* OK, I am recalling that long ago and far away, the Alteon AceNIC (PCI) had 
very high DMA setup times - so long that if an outbound (in this case) packet 
was more than 1.something buffers the card was unable to acheive link-rate with 
a 1500 byte MTU.  It meant that for straight copy outbound was fine, but for 
copy avoided (eg sendfile() - this was HP-UX 11) one was sub-par because it was 
at least two buffers per packet - aka two DMA setups - and sometimes three.  One 
workaround was to use JumboFrames - the larger MTU helped.

> 
> 
> But HW LRO is not bridge/forwarding/etc. agnostic because it loses
> information.
> 
> As soon as I turn on forwarding to make a NAT box or whatever, all of
> the hw LRO gets turned off and we're back to square one for local
> connections on the machine.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

