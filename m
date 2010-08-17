From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Tue, 17 Aug 2010 13:05:49 -0700
Message-ID: <AANLkTimGFu8PPBtjkT+H4agjQ_Dvfqr3K2RFy1Z_78x+@mail.gmail.com>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
	<20100812120044.5b1880ad@s6510>
	<20100812121600.2e971e66@s6510>
	<AANLkTinM2m-dK2FYw5VBi3eBAhBRrrzZ+vH5aCtDoDVS@mail.gmail.com>
	<20100812151819.282636fe@s6510>
	<AANLkTimWmJ5mTOswT8oJx7MXckzDWcSySZdAu6HZb6r7@mail.gmail.com>
	<20100817123702.3d09a35b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61499 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab0HQUFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 16:05:51 -0400
Received: by eyg5 with SMTP id 5so2258723eyg.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 13:05:50 -0700 (PDT)
In-Reply-To: <20100817123702.3d09a35b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also, the driver could schedule a reset (that is what the watchdog does),
> but it looks like the receive DMA is walking past the end of the packet
> and that is really dangerous since it could clobber random memory.

I'm not sure to what watchdog you are referring.
I'm not aware of this machine having a hw (or sw) watchdog.

> You might want to increase the size of rx DMA buffer and dump the
> contents of the receive buffer to see if there is a memory corruption

Is this something that is a userspace tweak (how? pointers please?),
or do you mean to modify the kernel source code and recompile.

> risk. If the End Of Frame DMA hardware is not working, there is a real
> danger if the driver silently continues.

Agreed, although that does seem to be what the driver is currently
doing... silently continuing.

---

BTW, I've run into the issue once more and I've verified that turning
off all acceleration options
doesn't fix the problem (ethtool -k eth0 rx off tx off sg off tso off
gso off [ufo/gro/lro already were off]), nor does trying to get
the network card to renegotiate the link speed (ethtool -s eth0 speed
10; sleep 5; ethtool -s eth0 speed 1000; sleep 5; ethtool -r eth0).

I am now testing to see if the problem ever occurs if all the
acceleration options are turned off.
Of late the occurrence rate seems to be pretty steady at about twice per week.

Maciej
