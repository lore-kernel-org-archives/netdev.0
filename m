From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: net: wireless: ath: wil6210: constify cfg80211_ops structures
Date: Thu, 12 Jan 2017 11:55:43 +0100
Message-ID: <66ab58f4a83d4164ae06cbb27fb38904@euamsexm01a.eu.qualcomm.com>
References: <1482014667-27082-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <qca_merez@qca.qualcomm.com>,
        <kvalo@codeaurora.org>, <linux-wireless@vger.kernel.org>,
        <wil6210@qca.qualcomm.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:11871 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdALKzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 05:55:52 -0500
In-Reply-To: <1482014667-27082-1-git-send-email-bhumirks@gmail.com>
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
>   18133	   6632	      0	  24765	   60bd wireless/ath/wil6210/cfg80211.o
> 
> File size after:
>    text	   data	    bss	    dec	    hex	filename
>   18933	   5832	      0	  24765	   60bd wireless/ath/wil6210/cfg80211.o
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to ath-next branch of ath.git, thanks.

b59eb96181e7 wil6210: constify cfg80211_ops structures

-- 
https://patchwork.kernel.org/patch/9479127/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
