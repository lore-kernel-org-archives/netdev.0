From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: forcedeth
Date: Sun, 01 Aug 2004 21:14:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410D4120.2020604@colorfullife.com>
References: <410D3377.3030505@tampabay.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: James Drabb <JDrabb@tampabay.rr.com>
In-Reply-To: <410D3377.3030505@tampabay.rr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Drabb wrote:

> jim@keelie $ uname -a
> Linux keelie 2.6.7-1 #1 Thu Jul 22 11:42:58 CEST 2004 i686 athlon i386 
> GNU/Linux

There should be a message in the dmesg log about the driver version: If 
it's less than 0.28: could you try a newer kernel? 0.28 is definitively 
in 2.5.8-rc1-mm1 and later. I could also send you just the forcedeth.c 
file, then you don't have to upgrade the whole kernel.

> However, if I reboot into WinXP, and then reboot right away back into 
> FC2, the forcedeth driver works like a champ.

Probably the phy reset and/or the media detection do not work properly. 
That part is completely rewritten in 0.28.

I'm interested in two infos:
- with 2.6.7 (probably version 0.25), after booting into winXP first: 
what does
    # ethtool eth0
report? Then unplug the network cable. Run ethtool again. Does it report 
"Link detected: No"? What if you plug the network cable back in?

- The same thing with the 0.28 driver.

Note that the phy initialization in 0.28 is not perfect either: it seems 
there is a race between the phy reset and the media detection. You might 
have to wait 2 seconds or so between modprobe and ifup.

--
    Manfred
