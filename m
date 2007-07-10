From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: [2.6 patch] the scheduled sk98lin removal
Date: Tue, 10 Jul 2007 12:09:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0707101156320.20119@potato.cts.ucla.edu>
References: <20070709145916.GE3492@stusta.de> <4693B773.2080205@garzik.org>
 <20070710094954.788aa357@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, Adrian Bunk <bunk@stusta.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-5.smtp.ucla.edu ([169.232.47.137]:44949 "EHLO
	smtp-5.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbXGJUD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 16:03:28 -0400
In-Reply-To: <20070710094954.788aa357@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007, Stephen Hemminger wrote:

> On Tue, 10 Jul 2007 12:44:35 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
>
>> Adrian Bunk wrote:
>>> This patch contains the scheduled removal of the sk98lin driver.
>>>
>>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>>
>> Stephen -- ACK?
>
> Yes.  Existing driver is dead, if there are any ancient boards that don't
> work with skge, I haven't heard any complaints in at least a year.
> As a fallback users, can always go with vendor driver.

I have a several SK-9872s that do not work reliably with skge but work 
fine with sklin.  The SK-9872 is a dual port card.  Doing the following 
causes a hard lock:

modprobe bonding miimon=100 mode=active-backup
modprobe skge
ifup bond0
ifdown bond0

This happens with every version of skge I've tested, including whatever is 
in 2.6.22.  /etc/network/interfaces contains:

iface bond0 inet static
         network 192.168.1.0
         address 192.168.1.1
         broadcast 192.168.1.255
         netmask 255.255.255.0

         up ifenslave bond0 eth0 eth1
         down ifenslave -d bond0 eth0 eth1


lspci -vv -s 02:01
02:01.0 Ethernet controller: SysKonnect SK-9872 Gigabit Ethernet Server Adapter (SK-NET GE-ZX dual link) (rev 11)
         Subsystem: SysKonnect SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 22
         Region 0: Memory at febfc000 (32-bit, non-prefetchable) [size=16K]
         Region 1: I/O ports at e800 [size=256]
         Expansion ROM at febc0000 [disabled] [size=128K]
         Capabilities: <access denied>




-Chris
