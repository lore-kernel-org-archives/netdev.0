From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100
 patch)
Date: Tue, 8 May 2007 17:06:17 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705081704050.12001@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
 <23552.1173395045@death> <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
 <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
 <Pine.LNX.4.64.0705081516580.12001@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-8.smtp.ucla.edu ([169.232.47.138]:42812 "EHLO
	smtp-8.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967378AbXEIA00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 20:26:26 -0400
In-Reply-To: <Pine.LNX.4.64.0705081516580.12001@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007, Chris Stromsoe wrote:
> On Mon, 12 Mar 2007, Chris Stromsoe wrote:
>> On Thu, 8 Mar 2007, Chris Stromsoe wrote:
>>> On Thu, 8 Mar 2007, Jay Vosburgh wrote:
>>>> Chris Stromsoe <cbs@cts.ucla.edu> wrote:
>>>> 
>>>>> 1) ip link set mtu 9000 eth2  <-- eth2 is no longer responsive
>>>>>    ip link set mtu 1500 eth2  <-- eth2 remains unresponsive
>>>>> 
>>>>> 2) ifup eth2
>>>>>    ifdown eth2
>>>>>
>>>>>    perl -pi -e 's/eth2/eth3/' /etc/network/interfaces
>>>>>
>>>>>    ifup eth3   <--  locks up here
>>>>
>>>> 	This would seem to suggest a problem with skge itself, although there 
>>>> might be some other interaction with bonding that causes the problems for 
>>>> that case.
>>> 
>>> In both of the above mentioned cases, I was not using bonding.  That was 
>>> with the skge driver only.
>> 
>> The above tests both work fine with the 2.6.20.1 sk98lin driver loaded as 
>> "modprobe sk98lin RlmtMode=DualNet".
>> 
>> I can change the MTU, add and remove eth2/eth3 from the bond, and up and 
>> down the interface.  It also works fine with different hardware (e100, 
>> e1000, tg3, bnx2).  Running both interfaces alone without the bonding 
>> driver also works (I can up and down the interfaces with no side-affects).
>
> Just an update - it looks like 2.6.20.1 fixed the MTU problem ("1" above), 
> but not the other problem (where the machine locks up if the second port on 
> the dual-port card is downed).
>
> To recap:
>
> I am use SysKonnect SK-9843 cards.  The sk98lin driver works fine; the skge

I should proof-read first.  The cards are SK-9844s, not SK-9843s.  The 
rest of the prior message is still correct.



-Chris

> driver does not.  The following sequence of commands locks up the server. 
> The lock is a hard lock; console is not responsive to keyboard input or to 
> sysrq.  Nothing is printed on the serial console.
>
>
>  ip li set eth2 up
>  ip li set eth2 down
>  ip li set eth3 up
>
>
> There are no addresses assigned to either interface.  This was done after a 
> fresh boot.  It is repeatable.  If I do not down eth2, I can up eth3 assign 
> addresses, and use both interfaces.
>
> The kernel is fresh from kernel.org and does not have any third party 
> patches.
>
> lspci -vv output:
>
> 0000:01:0a.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx 
> Gigabit Ethernet Server Adapter (rev 12)
>        Subsystem: Syskonnect (Schneider & Koch) SK-9844 Gigabit Ethernet  Server Adapter (SK-NET GE-SX dual link)
>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>        Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 0x08 (32 bytes)
>        Interrupt: pin A routed to IRQ 10
>        Region 0: Memory at ff8fc000 (32-bit, non-prefetchable) [size=16K]
>        Region 1: I/O ports at d800 [size=256]
>        Expansion ROM at ff400000 [disabled] [size=128K]
>        Capabilities: <available only to root>
>
>
>
>
> -Chris
>
