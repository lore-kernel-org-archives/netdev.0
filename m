From: Andy Lutomirski <luto@myrealbox.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 13:02:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408AC7DC.8060204@myrealbox.com>
References: <OFD9C928E8.B270E69A-ON87256E80.0069EECE-86256E80.006C0C7E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
In-Reply-To: <OFD9C928E8.B270E69A-ON87256E80.0069EECE-86256E80.006C0C7E@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason wrote:

>>BTW, what was it there for in the first place?  I can get gigabit to 
>>fail to negotiate, but I always pick up a 100Mbps/full duplex link when 
>>that happens.  I've never seen a complete absense of link.  I left the 
>>original semantics around because I assumed there was a reason, but if 
>>it's unnecessary, then the timer should only need to fire once during 
>>the lifetime of the device (and the assorted bookkeeping can go away).
> 
> 
> I have an 8110S version of the chipset, and I don't have any problems with 
> it getting an improper link speed form the outset.  Though, I am running 
> point-to-point with an e1000 adapter.  Are you running this through a 
> switch?

The 8001S was a typo -- mine is 8110S point-to-point with an e1000 on 
Windows.  Strangely enough, I can't reproduce the problem today.  It 
happened about 80% of the time yesterday, though.  I don't think I 
changed anything.  Maybe my cable's bad.

In any case, if I'm the only one with this problem, and no one knows 
what the original purpose of the timer was, I'm ok with removing it 
entirely.  I can work around this issue in userspace easily enough.

> 
> BTW, good work doing the link changes.  Though it might be beneficial to 
> do a "printk(KERN_INFO "%s: Link Down\n", dev->name);" in the interrupt 
> handler to show that the link is down in the dmesg (and a Link Up message 
> too).
> 

I left it out b/c natsemi does it and it always annoys me ;)  Is there a 
userspace tool for linkwatch?

In any case, what's the preferred approach?  natsemi notifies, tulip 
doesn't, and, IIRC, e1000 and tg3 don't.  If the consensus is to notify, 
shouldn't it be done in netif_carrier_on and netif_carrier_off?

--Andy
