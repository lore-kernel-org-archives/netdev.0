From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] libertas: Don't mark exported symbols as static
Date: Fri, 8 Feb 2008 16:28:24 -0800
Message-ID: <20080208162824.461451e1@extreme>
References: <adatzkj0z7l.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:46312 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbYBIA2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 19:28:37 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JNda4-0007Hs-39
	for netdev@vger.kernel.org; Sat, 09 Feb 2008 00:28:32 +0000
Received: from 75-175-36-50.ptld.qwest.net ([75.175.36.50])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2008 00:28:32 +0000
Received: from shemminger by 75-175-36-50.ptld.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2008 00:28:32 +0000
In-Reply-To: <adatzkj0z7l.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Feb 2008 16:07:26 -0800
Roland Dreier <rdreier@cisco.com> wrote:

> Marking exported symbols as static causes the following build error on
> ia64 with gcc 4.2.3:
> 
> drivers/net/wireless/libertas/main.c:1375: error: __ksymtab_lbs_remove_mesh causes a section type conflict
> drivers/net/wireless/libertas/main.c:1354: error: __ksymtab_lbs_add_mesh causes a section type conflict
> 
> Therefore, remove the static marking on lbs_remove_mesh and lbs_add_mesh.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index 84fb49c..a688ce8 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -253,8 +253,8 @@ static ssize_t lbs_anycast_set(struct device *dev,
>  
>  static int lbs_add_rtap(struct lbs_private *priv);
>  static void lbs_remove_rtap(struct lbs_private *priv);
> -static int lbs_add_mesh(struct lbs_private *priv);
> -static void lbs_remove_mesh(struct lbs_private *priv);
> +int lbs_add_mesh(struct lbs_private *priv);
> +void lbs_remove_mesh(struct lbs_private *priv);
>  
>  
>  /**
> @@ -1296,7 +1296,7 @@ EXPORT_SYMBOL_GPL(lbs_stop_card);
>   *  @param priv    A pointer to the struct lbs_private structure
>   *  @return 	   0 if successful, -X otherwise
>   */
> -static int lbs_add_mesh(struct lbs_private *priv)
> +int lbs_add_mesh(struct lbs_private *priv)
>  {
>  	struct net_device *mesh_dev = NULL;
>  	int ret = 0;
> @@ -1354,7 +1354,7 @@ done:
>  EXPORT_SYMBOL_GPL(lbs_add_mesh);
>  
>  
> -static void lbs_remove_mesh(struct lbs_private *priv)
> +void lbs_remove_mesh(struct lbs_private *priv)
>  {
>  	struct net_device *mesh_dev;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Why not pull the exports? they aren't used anywhere in the existing kernel.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>


