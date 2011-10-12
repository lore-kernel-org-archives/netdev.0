From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [patch net-2.6] tg3: negate USE_PHYLIB flag check
Date: Wed, 12 Oct 2011 16:55:01 -0700
Message-ID: <20111012235501.GA31550@mcarlson.broadcom.com>
References: <1318410041-2476-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Jiri Pirko" <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3298 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab1JLXzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 19:55:04 -0400
In-Reply-To: <1318410041-2476-1-git-send-email-jpirko@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 02:00:41AM -0700, Jiri Pirko wrote:
> USE_PHYLIB flag in tg3_remove_one() is being checked incorrectly. This
> results tg3_phy_fini->phy_disconnect is never called and when tg3 module
> is removed.
> 
> In my case this resulted in panics in phy_state_machine calling function
> phydev->adjust_link.
> 
> So correct this check.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Introduced by commit 63c3a66fe6c827a731dcbdee181158b295626f83, entitled
"tg3: Convert u32 flag,flg2,flg3 uses to bitmap".

Acked-by: Matt Carlson <mcarlson@broadcom.com>

> ---
>  drivers/net/tg3.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 4a1374d..c11a2b8 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -15577,7 +15577,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
>  
>  		cancel_work_sync(&tp->reset_task);
>  
> -		if (!tg3_flag(tp, USE_PHYLIB)) {
> +		if (tg3_flag(tp, USE_PHYLIB)) {
>  			tg3_phy_fini(tp);
>  			tg3_mdio_fini(tp);
>  		}
> -- 
> 1.7.6.2
> 
> 
