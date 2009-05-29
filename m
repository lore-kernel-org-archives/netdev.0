From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
	transmission when polling with KGDB
Date: Fri, 29 May 2009 06:46:46 -0400
Message-ID: <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	 <1243404615-25879-3-git-send-email-vapier@gentoo.org>
	 <20090529.020405.170805407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:33097 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbZE2Kqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:46:45 -0400
Received: by gxk10 with SMTP id 10so10235145gxk.13
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 03:46:47 -0700 (PDT)
In-Reply-To: <20090529.020405.170805407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 05:04, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Make sure data is really written into the registers before enabling DMA.
>> Otherwise, the EMAC DMA controller may transfer out a malformed packet.
>> This patch may also fix netperf bugs or scp bugs.
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>
> Instead of using this incredibly non-portable blackfin specific SSYNC
> thing

that doesnt make sense -- this is a completely non-portable Blackfin
specific driver.  everything in it uses Blackfin macros to access
Blackfin MMRs because this is a device that only exists on Blackfin
chips.

> why not read back a register from the device to ensure the
> register writes hit the chip just like other drivers do?

because that isnt how the Blackfin hardware works in general, and
certainly not how the DMA hardware works.

> If that doesn't work, enhance your commit message to describe (in
> detail) why SSYNC is the only way to make this work properly.

this is how it always is for all Blackfin on-chip registers, and the
hardware manual specifically dictates using SSYNC.
-mike
