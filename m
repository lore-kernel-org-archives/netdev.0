From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: TG3 data corruption (TSO ?)
Date: Mon, 11 Sep 2006 15:54:24 +0200
Message-ID: <15531494-BB50-49B3-B2A8-7E51AB3DDBF9@kernel.crashing.org>
References: <1551EAE59135BE47B544934E30FC4FC093FB2C@NT-IRVA-0751.brcm.ad.broadcom.com> <1157953925.31071.413.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-04.arcor-online.net ([151.189.21.44]:47257 "EHLO
	mail-in-04.arcor-online.net") by vger.kernel.org with ESMTP
	id S1750707AbWIKNyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 09:54:31 -0400
In-Reply-To: <1157953925.31071.413.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> #define tw32_rx_mbox(reg, val)	do { wmb();
>> tp->write32_rx_mbox(tp, reg, val); } while(0)
>>> #define tw32_tx_mbox(reg, val)	do { wmb();
>> tp->write32_tx_mbox(tp, reg, val); } while(0)
>>>
>>
>> That should do it.
>>
>> I think we need those tcpdump after all.  Can you send it to me?
>
> Looks like adding a sync to writel does fix it though... I'm trying to
> figure out which specific writel in the driver makes a difference.  
> I'll
> then look into slicing those tcpdumps.

Adding a PowerPC "sync" to every writel() will slow down things by
so much that it could well just hide the problem, not solve it...

Michael, we see this problem only with TSO on, and then the failure
we see is bad data being sent out, with the correct header (but the
header is constructed by the tg3 in this case, so no surprise).

I'm theorizing that this same failure can happen with TSO off as well,
but the header sent on the wire will be bogus as well as the data,
so the receiving NIC won't pick it up.  tcpdump probably won't see
it either...  will need a low-level ethernet analyser.


Segher

