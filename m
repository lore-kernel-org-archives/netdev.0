From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 14:44:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD9C928E8.B270E69A-ON87256E80.0069EECE-86256E80.006C0C7E@us.ibm.com>
References: <408A8252.5040006@stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jgarzik@pobox.com, Andy Lutomirski <luto@myrealbox.com>,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <408A8252.5040006@stanford.edu>
To: Andy Lutomirski <luto@stanford.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>As an added benefit, my 8001S often fails to negotiate 1000Mbps when 
the
>>>driver loads but will successfully negotiate it after a while.  Running
>>>'ethtool -s ethx autoneg on' fixes it, but that's absurd.  This patch
>>>will, ten seconds after the driver starts, check if 1000Mbps is 
advertised
>>>but not selected, and, if so, force a renegotiation.
>> 
>> 
>> So you can not reliably remove the phy timer and simply use the LinkChg 
status
>> change, right ?
>
>Apparently.  The timer only fires when necessary with my patch, though 
>(see the return statements in rtl8169_phy_timer).
>
>BTW, what was it there for in the first place?  I can get gigabit to 
>fail to negotiate, but I always pick up a 100Mbps/full duplex link when 
>that happens.  I've never seen a complete absense of link.  I left the 
>original semantics around because I assumed there was a reason, but if 
>it's unnecessary, then the timer should only need to fire once during 
>the lifetime of the device (and the assorted bookkeeping can go away).

I have an 8110S version of the chipset, and I don't have any problems with 
it getting an improper link speed form the outset.  Though, I am running 
point-to-point with an e1000 adapter.  Are you running this through a 
switch?

BTW, good work doing the link changes.  Though it might be beneficial to 
do a "printk(KERN_INFO "%s: Link Down\n", dev->name);" in the interrupt 
handler to show that the link is down in the dmesg (and a Link Up message 
too).

>> Is everybody fine if I cook up a series of patches for -netdev/-mm 
inclusion
>> which includes:
>> - your link related changes
>> - start of a 8139cp.c genetic mutation on top of those
>> - reworked Jon D Mason's NAPI changes

Looks like a fair amount of work to convert 8139cp to r8169.  Let me know 
if you need any help.
