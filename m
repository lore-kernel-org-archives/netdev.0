From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [2.6 patch] drivers/net/wireless/orinoco.h: "extern inline" -> "static inline"
Date: Fri, 18 Nov 2005 14:52:36 +1100
Message-ID: <20051118035236.GB23760@localhost.localdomain>
References: <20051118033329.GU11494@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: proski-mXXj517/zsQ@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20051118033329.GU11494-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2005 at 04:33:29AM +0100, Adrian Bunk wrote:
> "extern inline" doesn't make much sense.

Yes it does.  "extern inline" tells gcc not to fall back to out of
line version if it can't inline the function.  These functions *must*
by inlined, or they'll break horribly on Sparc, at least.

> --- linux-2.6.15-rc1-mm1-full/drivers/net/wireless/orinoco.h.old	2005-11-18 02:38:43.000000000 +0100
> +++ linux-2.6.15-rc1-mm1-full/drivers/net/wireless/orinoco.h	2005-11-18 02:38:47.000000000 +0100
> @@ -155,7 +155,7 @@
>   * SPARC, due to its weird semantics for save/restore flags. extern
>   * inline should prevent the kernel from linking or module from
>   * loading if they are not inlined. */
> -extern inline int orinoco_lock(struct orinoco_private *priv,
> +static inline int orinoco_lock(struct orinoco_private *priv,
>  			       unsigned long *flags)
>  {
>  	spin_lock_irqsave(&priv->lock, *flags);
> @@ -168,7 +168,7 @@
>  	return 0;
>  }
>  
> -extern inline void orinoco_unlock(struct orinoco_private *priv,
> +static inline void orinoco_unlock(struct orinoco_private *priv,
>  				  unsigned long *flags)
>  {
>  	spin_unlock_irqrestore(&priv->lock, *flags);
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
