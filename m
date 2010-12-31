From: David <david@unsolicited.net>
Subject: Re: Sky2 - problems with VLANs - kernel 2.6.36
Date: Fri, 31 Dec 2010 21:42:52 +0000
Message-ID: <4D1E4E5C.7030409@unsolicited.net>
References: <4CD48DE6.7060906@unsolicited.net> <20101231101303.6caed8ab@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.unsolicited.net ([173.255.193.191]:50789 "EHLO
	mx1.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab0LaWEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 17:04:13 -0500
In-Reply-To: <20101231101303.6caed8ab@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/12/10 18:13, Stephen Hemminger wrote:
> On Fri, 05 Nov 2010 23:06:14 +0000
> David <david@unsolicited.net> wrote:
>
>> I've just installed a Lycom dual port gigabit ethernet card, picked up
>> as follows :-
>>
>> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8062 PCI-E
>> IPMI Gigabit Ethernet Controller (rev 14)
>>     Subsystem: Marvell Technology Group Ltd. Device 6222
>>     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
>> Stepping- SERR+ FastB2B- DisINTx+
>>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>     Latency: 0, Cache Line Size: 64 bytes
>>     Interrupt: pin A routed to IRQ 41
>>     Region 0: Memory at fe8fc000 (64-bit, non-prefetchable) [size=16K]
>>     Region 2: I/O ports at c800 [size=256]
>>     Expansion ROM at fe8c0000 [disabled] [size=128K]
>>     Capabilities: <access denied>
>>     Kernel driver in use: sky2
>>     Kernel modules: sky2
>>
>> I'm having a problem with VLANs. Outgoing packets are tagged correctly
>> and devices on the VLAN are responding. Unfortunately all of the
>> response packets stay on the raw device and are not allocated to the VLAN.
>>
>> I've done some investigation (printks etc.), and have found that neither
>> of the following cases in sky2_status_intr() are being triggered...
>>
>>                 case OP_RXVLAN:
>>                         printk("RXVLAN, length=%u, status=%u\n", length,
>> status);
>>                         sky2->rx_tag = length;
>>                         break;
>>
>>                 case OP_RXCHKSVLAN:
>>                         printk("RXCHKSVLAN, length=%u, status=%u\n",
>> length, status);
>>                         sky2->rx_tag = length;
>>                         /* fall through */
>>
>> ... however the status when calling sky2_skb_rx() does have GMR_FS_VLAN
>> set, it's just we haven't been able to find out which VLAN the packet
>> comes from (and sky2->rx_tag is zero). Does anyone have any suggestions
>> as to how I proceed from here? I'm happy to test patches etc.
> Did it work with older kernels? 
Unfortunately I don't know (as this was a new hardware setup). Since it was a while ago and no-one seemed to have any ideas, I fixed the problem by changing to an e1000 (which had no further issues).
I've still got the offending hardware though, so it may be possible to throw some older distros at it to test.

Cheers
David

