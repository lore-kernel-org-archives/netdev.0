From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: net: wireless: marvell: libertas: constify cfg80211_ops structures
Date: Fri, 30 Dec 2016 13:02:42 +0000 (UTC)
Message-ID: <20161230130243.02DAF6145A@smtp.codeaurora.org>
References: <1482015444-28899-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, libertas-dev@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42896 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753973AbcL3NCo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 08:02:44 -0500
In-Reply-To: <1482015444-28899-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bhumika Goyal <bhumirks@gmail.com> wrote:
> cfg80211_ops structures are only passed as an argument to the function
> wiphy_new. This argument is of type const, so cfg80211_ops strutures
> having this property can be declared as const.
> Done using Coccinelle
> 
> @r1 disable optional_qualifier @
> identifier i;
> position p;
> @@
> static struct cfg80211_ops i@p = {...};
> 
> @ok1@
> identifier r1.i;
> position p;
> @@
> wiphy_new(&i@p,...)
> 
> @bad@
> position p!={r1.p,ok1.p};
> identifier r1.i;
> @@
> i@p
> 
> @depends on !bad disable optional_qualifier@
> identifier r1.i;
> @@
> +const
> struct cfg80211_ops i;
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>   21225	   1954	     16	  23195	   5a9b	wireless/marvell/libertas/cfg.o
> 
> File size after:
>    text	   data	    bss	    dec	    hex	filename
>   22041	   1154	     16	  23211	   5aab	wireless/marvell/libertas/cfg.o
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

The prefix should be "libertas:", I can fix that before I commit.

-- 
https://patchwork.kernel.org/patch/9479131/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
