From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
 transmission when polling with KGDB
Date: Fri, 29 May 2009 02:04:05 -0700 (PDT)
Message-ID: <20090529.020405.170805407.davem@davemloft.net>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	<1243404615-25879-3-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, vapier.adi@gmail.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753754AbZE2JEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:04:05 -0400
In-Reply-To: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 27 May 2009 02:10:12 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Make sure data is really written into the registers before enabling DMA.
> Otherwise, the EMAC DMA controller may transfer out a malformed packet.
> This patch may also fix netperf bugs or scp bugs.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

Instead of using this incredibly non-portable blackfin specific SSYNC
thing, why not read back a register from the device to ensure the
register writes hit the chip just like other drivers do?

If that doesn't work, enhance your commit message to describe (in
detail) why SSYNC is the only way to make this work properly.

I'm not applying this as-is.
