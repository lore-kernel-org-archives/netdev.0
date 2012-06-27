From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Build fix in drivers/net/wireless/ath/ath9k/main.c
Date: Wed, 27 Jun 2012 14:27:14 -0400
Message-ID: <20120627182713.GB1862@tuxdriver.com>
References: <1340824779-5157-1-git-send-email-asido4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcgrof@qca.qualcomm.com, jouni@qca.qualcomm.com,
	vthiagar@qca.qualcomm.com, senthilb@qca.qualcomm.com,
	linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arvydas Sidorenko <asido4@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340824779-5157-1-git-send-email-asido4@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, but Sujith beat you to the same fix.

John

On Wed, Jun 27, 2012 at 09:19:39PM +0200, Arvydas Sidorenko wrote:
> Commit fad29cd2f59949581050a937786c2c9bc78b2f04 broke the build if
> no CONFIG_ATH9K_BTCOEX_SUPPORT is enabled.
> 
> Signed-off-by: Arvydas Sidorenko <asido4@gmail.com>
> ---
>  drivers/net/wireless/ath/ath9k/main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
> index c14cf5a..e4e73f0 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -151,8 +151,10 @@ static void __ath_cancel_work(struct ath_softc *sc)
>  	cancel_delayed_work_sync(&sc->tx_complete_work);
>  	cancel_delayed_work_sync(&sc->hw_pll_work);
>  
> +#ifdef CONFIG_ATH9K_BTCOEX_SUPPORT
>  	if (ath9k_hw_mci_is_enabled(sc->sc_ah))
>  		cancel_work_sync(&sc->mci_work);
> +#endif
>  }
>  
>  static void ath_cancel_work(struct ath_softc *sc)
> -- 
> 1.7.8.6
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
