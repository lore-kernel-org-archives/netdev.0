From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] compile error in ieee80211_ioctl.c
Date: Sun, 23 Apr 2006 18:53:44 -0700
Message-ID: <20060423185344.aafafa73.rdunlap@xenotime.net>
References: <20060424002639.54669.qmail@web50214.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:60044 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751483AbWDXBvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 21:51:18 -0400
Received: from midway.site ([71.111.157.99]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 23 Apr 2006 18:51:17 -0700
To: Alex Davis <alex14641@yahoo.com>
In-Reply-To: <20060424002639.54669.qmail@web50214.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 23 Apr 2006 17:26:39 -0700 (PDT) Alex Davis wrote:

> Hello:
> 
> I cloned git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
> last night and got compile errors while compiling net/d80211/ieee80211_ioctl.c
> into a module. This patch fixes it.
> 
> Signed-off-by: Alex Davis <alex14641@yahoo.com>
> 
> diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
> index 42a7abe..4949e52 100644
> --- a/net/d80211/ieee80211_ioctl.c
> +++ b/net/d80211/ieee80211_ioctl.c
> @@ -30,7 +30,7 @@ #include "aes_ccm.h"
>  
>  
>  static int ieee80211_regdom = 0x10; /* FCC */
> -MODULE_PARM(ieee80211_regdom, "i");
> +module_param(ieee80211_regdom, int, 0x10);
>  MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");

The last parameter of module_param() is a permission value, not
an init value.  The int is already initialized above.
Typical permission values are 0, 0444, 0644, ... (octal,
or use the available #defines).

>  /*
> @@ -40,7 +40,7 @@ MODULE_PARM_DESC(ieee80211_regdom, "IEEE
>   * module.
>   */
>  static int ieee80211_japan_5ghz /* = 0 */;
> -MODULE_PARM(ieee80211_japan_5ghz, "i");
> +module_param(ieee80211_japan_5ghz, int, 0);
>  MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");

---
~Randy
