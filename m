From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
 transmission when polling with KGDB
Date: Fri, 29 May 2009 03:52:24 -0700 (PDT)
Message-ID: <20090529.035224.124353374.davem@davemloft.net>
References: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
	<20090529.020405.170805407.davem@davemloft.net>
	<8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754788AbZE2KwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:52:25 -0400
In-Reply-To: <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 06:46:46 -0400

> On Fri, May 29, 2009 at 05:04, David Miller wrote:
>> From: Mike Frysinger <vapier@gentoo.org>
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>
>>> Make sure data is really written into the registers before enabling DMA.
>>> Otherwise, the EMAC DMA controller may transfer out a malformed packet.
>>> This patch may also fix netperf bugs or scp bugs.
>>>
>>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
>>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>>
>> Instead of using this incredibly non-portable blackfin specific SSYNC
>> thing
> 
> that doesnt make sense -- this is a completely non-portable Blackfin
> specific driver.  everything in it uses Blackfin macros to access
> Blackfin MMRs because this is a device that only exists on Blackfin
> chips.

There is never an excuse to not write portable code when you can.

Some day we may have dummy do-nothing bus drivers for every platform
bus or subsystem, so that we can compile any driver on any platform.

Do you want to make that kind of build validation of you code harder?

>> why not read back a register from the device to ensure the
>> register writes hit the chip just like other drivers do?
> 
> because that isnt how the Blackfin hardware works in general, and
> certainly not how the DMA hardware works.

Have you tried reading the register back?  Does it work?

