From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH net-next V1 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Mon, 25 Aug 2014 14:06:14 -0400
Message-ID: <20140825180614.GH14379@redhat.com>
References: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933238AbaHYSGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 14:06:37 -0400
Content-Disposition: inline
In-Reply-To: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 04:06:51PM +0300, Amir Vadai wrote:
> Hi,
> 
> I'm re-spinning this patchset. At the begining it was suggested to use a
> different name for the parameter, but at the end [3] the resolution was to
> leave it as it is in this patch.
> 
> Drivers need to know if running from kdump kernel in order to change their
> memory profile - since kdump environment is limited by available memory.
> Currently there are drivers that are using reset_devices as suggested in [2].
> In [2] it was suggested to use reset_devices, but the context was, to enable
> driver to know when the hardware device is needed to be reset, and not if this
> is a kdump environment. We think that is_kdump_kernel() is better suited to
> select between different memory profiles.
> 
> The first patch in this patchset exports a needed symbol in order to make
> is_kdump_kernel() accessible from the drivers. The rest of the patches change
> from reset_devices to is_kdump_kernel() in 2 networking drivers.
> 
> The idea of this patchset was suggested by Vivek Goyal.
> 
> Tested (only build) and applied on top of commit 8fc54f6: ("net: use
> reciprocal_scale() helper")
> 
> [1] - ea1c1af: ("net/mlx4_en: Reduce memory consumption on kdump kernel")
> [2] - https://lkml.org/lkml/2011/1/27/341
> [3] - http://www.spinics.net/lists/netdev/msg291492.html
> 
> Thanks,
> Amir

Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Vivek

> 
> Amir Vadai (3):
>   crash_dump: Make is_kdump_kernel() accessible from modules
>   net/mlx4: Use is_kdump_kernel() to detect kdump kernel
>   net/bnx2x: Use is_kdump_kernel() to detect kdump kernel
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 3 ++-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
>  include/linux/mlx4/device.h                      | 3 ++-
>  kernel/crash_dump.c                              | 1 +
>  4 files changed, 7 insertions(+), 3 deletions(-)
> 
> -- 
> 1.8.3.4
