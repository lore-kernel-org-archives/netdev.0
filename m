From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 29122] New: r6040: interface status messaged
 logged once per second
Date: Mon, 14 Feb 2011 12:15:45 -0800
Message-ID: <20110214121545.a8bf1356.akpm@linux-foundation.org>
References: <bug-29122-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, signtalk000@aol.com,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35354 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab1BNUQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 15:16:30 -0500
In-Reply-To: <bug-29122-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 14 Feb 2011 19:39:50 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=29122
> 
>            Summary: r6040: interface status messaged logged once per
>                     second
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.35.10
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: signtalk000@aol.com
>         Regression: No
> 
> 
> In the following patch by Florian Fainelli - 2010-05-16, the added call to
> mii_check_media() has the "printit" flag, the 2nd parameter, set which causes a
> status message to be logged once per second.
> 
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 4122916..eeee379 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -400,9 +400,6 @@  static void r6040_init_mac_regs(struct net_device *dev)
>       * we may got called by r6040_tx_timeout which has left
>       * some unsent tx buffers */
>      iowrite16(0x01, ioaddr + MTPR);
> -
> -    /* Check media */
> -    mii_check_media(&lp->mii_if, 1, 1);
>  }
> 
>  static void r6040_tx_timeout(struct net_device *dev)
> @@ -530,8 +527,6 @@  static int r6040_phy_mode_chk(struct net_device *dev)
>              phy_dat = 0x0000;
>      }
> 
> -    mii_check_media(&lp->mii_if, 0, 1);
> -
>      return phy_dat;
>  };
> 
> @@ -813,6 +808,9 @@  static void r6040_timer(unsigned long data)
> 
>      /* Timer active again */
>      mod_timer(&lp->timer, round_jiffies(jiffies + HZ));
> +
> +    /* Check media */
> +    mii_check_media(&lp->mii_if, 1, 1);
>  }
> 
>  /* Read/set MAC address routines */
> 

