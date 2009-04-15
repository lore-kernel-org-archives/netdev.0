From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: [PATCH] phylib: Fix delay argument of schedule_delayed_work
Date: Wed, 15 Apr 2009 20:37:19 +0200
Message-ID: <49E6295F.80009@gmail.com>
References: <1239811551-6101-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755658AbZDOSi1@vger.kernel.org>
In-Reply-To: <1239811551-6101-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> The commit a390d1f3 ("phylib: convert state_queue work to
> delayed_work") missed converting 'expires' value to 'delay' value.

Yeah, sorry about that.

> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Acked-by: Marcin Slusarz <marcin.slusarz@gmail.com>

> ---
>  drivers/net/phy/phy.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 3ff1f42..5737b85 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -434,7 +434,7 @@ void phy_start_machine(struct phy_device *phydev,
>  	phydev->adjust_state = handler;
>  
>  	INIT_DELAYED_WORK(&phydev->state_queue, phy_state_machine);
> -	schedule_delayed_work(&phydev->state_queue, jiffies + HZ);
> +	schedule_delayed_work(&phydev->state_queue, HZ);
>  }
>  
>  /**
> @@ -937,6 +937,5 @@ static void phy_state_machine(struct work_struct *work)
>  	if (err < 0)
>  		phy_error(phydev);
>  
> -	schedule_delayed_work(&phydev->state_queue,
> -				jiffies + PHY_STATE_TIME * HZ);
> +	schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
>  }
