From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RESEND] libertas: Remove unused exports
Date: Mon, 25 Feb 2008 14:12:04 -0500
Message-ID: <1203966724.6981.29.camel@localhost.localdomain>
References: <adatzkj0z7l.fsf@cisco.com> <adaprv1vkl7.fsf@cisco.com>
	 <aday79b571e.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <aday79b571e.fsf_-_-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2008-02-23 at 20:10 -0800, Roland Dreier wrote:
> Any chance of getting this applied?  It seems the build is still
> broken on ia64 at least due to the export of static functions.
> ---

Normal route is to linux-wireless@...

However; if the symbols aren't used anywhere in
drivers/net/wireless/libertas/*, it makes no sense to keep them around &
exported.

Acked-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> 
> The libertas driver exports a number of symbols with no in-tree
> users; remove these unused exports.  lbs_reset_device() is completely
> unused, with no callers at all, so remove the function completely.
> 
> A couple of these unused exported symbols are static, which causes the
> following build error on ia64 with gcc 4.2.3:
> 
>     drivers/net/wireless/libertas/main.c:1375: error: __ksymtab_lbs_remove_mesh causes a section type conflict
>     drivers/net/wireless/libertas/main.c:1354: error: __ksymtab_lbs_add_mesh causes a section type conflict
> 
> This patch fixes this problem.  I don't have hardware, so this is not
> run-tested, but I tested the build with
> 
>     CONFIG_LIBERTAS=y
>     CONFIG_LIBERTAS_USB=m
>     CONFIG_LIBERTAS_CS=m
>     CONFIG_LIBERTAS_SDIO=m
> 
> and there were no problems with undefined symbols.
> 
> Signed-off-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> ---
> diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
> index eab0203..b3c1acb 100644
> --- a/drivers/net/wireless/libertas/cmd.c
> +++ b/drivers/net/wireless/libertas/cmd.c
> @@ -1040,7 +1040,6 @@ int lbs_mesh_access(struct lbs_private *priv, uint16_t cmd_action,
>  	lbs_deb_leave(LBS_DEB_CMD);
>  	return ret;
>  }
> -EXPORT_SYMBOL_GPL(lbs_mesh_access);
>  
>  int lbs_mesh_config(struct lbs_private *priv, uint16_t enable, uint16_t chan)
>  {
> @@ -1576,7 +1575,6 @@ done:
>  	lbs_deb_leave_args(LBS_DEB_HOST, "ret %d", ret);
>  	return ret;
>  }
> -EXPORT_SYMBOL_GPL(lbs_prepare_and_send_command);
>  
>  /**
>   *  @brief This function allocates the command buffer and link
> diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
> index aaacd9b..4e22341 100644
> --- a/drivers/net/wireless/libertas/decl.h
> +++ b/drivers/net/wireless/libertas/decl.h
> @@ -69,7 +69,6 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev);
>  int lbs_remove_card(struct lbs_private *priv);
>  int lbs_start_card(struct lbs_private *priv);
>  int lbs_stop_card(struct lbs_private *priv);
> -int lbs_reset_device(struct lbs_private *priv);
>  void lbs_host_to_card_done(struct lbs_private *priv);
>  
>  int lbs_update_channel(struct lbs_private *priv);
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index 84fb49c..1eaf6af 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -1351,8 +1350,6 @@ done:
>  	lbs_deb_leave_args(LBS_DEB_MESH, "ret %d", ret);
>  	return ret;
>  }
> -EXPORT_SYMBOL_GPL(lbs_add_mesh);
> -
>  
>  static void lbs_remove_mesh(struct lbs_private *priv)
>  {
> @@ -1372,7 +1369,6 @@ static void lbs_remove_mesh(struct lbs_private *priv)
>  	free_netdev(mesh_dev);
>  	lbs_deb_leave(LBS_DEB_MESH);
>  }
> -EXPORT_SYMBOL_GPL(lbs_remove_mesh);
>  
>  /**
>   *  @brief This function finds the CFP in
> @@ -1458,20 +1454,6 @@ void lbs_interrupt(struct lbs_private *priv)
>  }
>  EXPORT_SYMBOL_GPL(lbs_interrupt);
>  
> -int lbs_reset_device(struct lbs_private *priv)
> -{
> -	int ret;
> -
> -	lbs_deb_enter(LBS_DEB_MAIN);
> -	ret = lbs_prepare_and_send_command(priv, CMD_802_11_RESET,
> -				    CMD_ACT_HALT, 0, 0, NULL);
> -	msleep_interruptible(10);
> -
> -	lbs_deb_leave_args(LBS_DEB_MAIN, "ret %d", ret);
> -	return ret;
> -}
> -EXPORT_SYMBOL_GPL(lbs_reset_device);
> -
>  static int __init lbs_init_module(void)
>  {
>  	lbs_deb_enter(LBS_DEB_MAIN);
