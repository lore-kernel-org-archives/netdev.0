From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: RX problem in ibm_newemac driver
Date: Wed, 11 Mar 2009 00:14:48 +0200
Message-ID: <49B6E658.4010900@embedded-sol.com>
References: <49B6C4A2.8060302@embedded-sol.com> <1236718202.7086.10.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:40903 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbZCJWOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 18:14:55 -0400
In-Reply-To: <1236718202.7086.10.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> On Tue, 2009-03-10 at 21:50 +0200, Felix Radensky wrote:
>   
>> Hi,
>>
>> I'm experiencing RX problem on custom board based on AMCC
>> 405EXr processor. Channel 0 of EMAC is connected to 10/100
>> Micrel KSZ8041NL PHY in MII mode. Ethernet works fine in
>> u-boot (version 2009.01). In Linux (2.6.27) Ethernet works fine
>> as well if EMAC was initialized in u-boot. It is enough to send
>> ping from u-boot (even to non-existing host) to make things work
>> in linux. But if u-boot takes kernel and ramdisk images from flash
>> and does not initialize EMAC only TX side works in linux.
>>     
>
> You should CC linuxppc-dev where you are more likely to find people to
> help here.
>
>   

I've sent a message to linuxppc-dev yesterday, but didn't get any reply 
so far.
>> I can see that TX counters are incremented when pinging from
>> EMAC side, but RX counters remain zero.  RX error counter
>> in PHY is zero as well.  I've enabled debugging in EMAC
>> driver and verified that RX EOB interrupt is not triggered.
>> FER register in RGMII bridge is properly configured for MII
>> mode on channel 0.  I've tried to dump EMAC registers using
>> ethtool and got machine check exception.
>>
>> I don't know what else could be done to identify the source of
>> the problem. Any tips would be greatly appreciated.
>>     
>
> I don't have a 405EXr here, but it smells like the old reset problem
> when the link is down. Maybe we are missing code to force clocks on
> 405EXr when there's no link ?
>   

Yes, seems logical. U-boot has code to enable and disable loopback clock
for 440SPE, 440EPX,440GRX,405EX, 460EX and 460GT.

I can test patches on my board. Alternatively, I can try something myself
if you can provide some guidance. I guess you are referring to the code 
using
EMAC_FTR_440GX_PHY_CLK_FIX and EMAC_FTR_440EP_PHY_CLK_FIX.

Thanks.

Felix.

