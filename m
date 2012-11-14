From: Daniele Venzano <venza@brownhat.org>
Subject: Re: PROBLEM: freeze when resuming from suspend-to-ram
Date: Wed, 14 Nov 2012 22:11:15 +0100
Message-ID: <20121114211115.GD14880@ge.brownhat.org>
References: <1560844.T75lq5MbC7@brinja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: medhefgo@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.infomaniak.ch ([84.16.68.91]:54868 "EHLO
	smtp3.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641Ab2KNVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 16:19:07 -0500
Content-Disposition: inline
In-Reply-To: <1560844.T75lq5MbC7@brinja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 11, 2012 at 08:47:45PM +0100, medhefgo@web.de wrote:
> Hello, 
> 
> When resuming from suspend-to-ram the kernel freezes. Git bisect output below. 
> When removing the sis900 module or if eth0 hasn't yet been brought up with "ip 
> link set eth0 up", resuming works fine.
> 
> This is happening on a up-to-date Arch installation with kernel 3.6.6 and is 
> still present in 3.7-rc5. Reverting the patch is possible and fixes the 
> freezing.

The patch is big and, while by looking at it nothing jumps to my eyes as
clearly wrong, I currently do not have access to sis900 hardware to test
it. Francois Romieu (in CC), who did the patch, perhaps can shed some light.

Otherwise I cannot work on it before next month, when I'll be able to
put my hands on the hardware.

> 57d6d456cfb89264f87d24f52640ede23fdf12bd is the first bad commit
> commit 57d6d456cfb89264f87d24f52640ede23fdf12bd
> Author: Francois Romieu <romieu@fr.zoreil.com>
> Date:   Tue Mar 13 11:14:17 2012 +0100
> 
>     sis900: stop using net_device.{base_addr, irq} and convert to __iomem.
>     
>     - pci_resource_start() can be removed from sis900_get_mac_addr() because
>       the IO range is maped and stored into the device private struct early
>       in the device probe function.
>     - the driver contains a few direct accesses to low IO ports that forbid
>       to re(#)define the usual out{l, w, b} macros.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Daniele Venzano <venza@brownhat.org>
> 
> :040000 040000 f328a3383c1ff9b9ed16de7272b4c8a302ae2812 
> 44c07bfe1bd23b381fd407dfaa9591ed26165afd M      drivers

Thanks.

-- 
Daniele Venzano
http://www.brownhat.org
