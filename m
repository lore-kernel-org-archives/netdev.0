From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: cancel timer on device removal
Date: Fri, 29 Apr 2011 12:20:51 -0700
Message-ID: <1304104851.12355.125.camel@nseg_linux_HP1.broadcom.com>
References: <1303849811-29025-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4622 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759221Ab1D2T0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 15:26:54 -0400
In-Reply-To: <1303849811-29025-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-04-26 at 13:30 -0700, Neil Horman wrote:
> Fix the problem by ensuring that the timer is stopped when
> pci_device_unregister
> is called.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Hushan Jia <hjia@redhat.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: "David S. Miller" <davem@davemloft.net>

Thanks Neil.

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index bf729ee..7f76d4c 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -8358,6 +8358,8 @@ bnx2_remove_one(struct pci_dev *pdev)
>  
>         unregister_netdev(dev);
>  
> +       del_timer_sync(&bp->timer);
> +
>         if (bp->mips_firmware)
>                 release_firmware(bp->mips_firmware);
>         if (bp->rv2p_firmware)


