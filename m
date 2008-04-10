From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] smc911x: test after postfix decrement fails in smc911x_{reset,drop_pkt}
Date: Thu, 10 Apr 2008 11:00:03 +0200
Message-ID: <87abk2axv0.fsf@macbook.be.48ers.dk>
References: <47FC922A.6030309@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Roel Kluin <12o3l@tiscali.nl>, jeff@garzik.org, dustin@sensoria.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756508AbYDJJAg@vger.kernel.org>
In-Reply-To: <47FC922A.6030309@tiscali.nl> (Roel Kluin's message of "Wed\, 09 Apr 2008 11\:53\:46 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Roel" == Roel Kluin <12o3l@tiscali.nl> writes:

 Roel> When timeout reaches 0 the postfix decrement still subtracts,
 Roel> so the test fails

Ahh, good catch. Notice that Nicolas isn't the author of smc911x,
Dustin McIntire is.

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

 Roel> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
 Roel> ---
 Roel> diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
 Roel> index 76cc1d3..2126d24 100644
 Roel> --- a/drivers/net/smc911x.c
 Roel> +++ b/drivers/net/smc911x.c
 Roel> @@ -243,7 +243,7 @@ static void smc911x_reset(struct net_device *dev)
 Roel>  		do {
 Roel>  			udelay(10);
 Roel>  			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
 Roel> -		} while ( timeout-- && !reg);
 Roel> +		} while ( --timeout && !reg);
 Roel>  		if (timeout == 0) {
 Roel>  			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
 Roel>  			return;
 Roel> @@ -267,7 +267,7 @@ static void smc911x_reset(struct net_device *dev)
 Roel>  				resets++;
 Roel>  				break;
 Roel>  			}
 Roel> -		} while ( timeout-- && (reg & HW_CFG_SRST_));
 Roel> +		} while ( --timeout && (reg & HW_CFG_SRST_));
 Roel>  	}
 Roel>  	if (timeout == 0) {
 Roel>  		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
 Roel> @@ -413,7 +413,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 Roel>  		do {
 Roel>  			udelay(10);
 Roel>  			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
 Roel> -		} while ( timeout-- && reg);
 Roel> +		} while ( --timeout && reg);
 Roel>  		if (timeout == 0) {
 Roel>  			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 Roel>  		}
 Roel> --

-- 
Bye, Peter Korsgaard
