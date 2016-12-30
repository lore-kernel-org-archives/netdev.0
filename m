From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: net: wireless: ath: wil6210: constify cfg80211_ops structures
Date: Fri, 30 Dec 2016 13:01:07 +0000 (UTC)
Message-ID: <20161230130107.3C0256145A@smtp.codeaurora.org>
References: <1482014667-27082-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, qca_merez@qca.qualcomm.com,
        linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482014667-27082-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
>   18133	   6632	      0	  24765	   60bd wireless/ath/wil6210/cfg80211.o
> 
> File size after:
>    text	   data	    bss	    dec	    hex	filename
>   18933	   5832	      0	  24765	   60bd wireless/ath/wil6210/cfg80211.o
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

The prefix should be "wil6210:", I can fix that before I commit this.

-- 
https://patchwork.kernel.org/patch/9479127/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
