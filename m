From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac
	cards
Date: Mon, 30 Oct 2006 09:50:41 +0100
Message-ID: <1162198241.2854.13.camel@ux156>
References: <200610031457.33215.chunkeey@web.de>
	 <20061017213229.GC32614@tuxdriver.com> <200610291335.07729.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:10410 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751771AbWJ3Itm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 03:49:42 -0500
To: chunkeey@web.de
In-Reply-To: <200610291335.07729.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-10-29 at 14:35 +0200, chunkeey@web.de wrote:

> +#define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]: 
> +#define MACSTR "%02x: %02x:%02x:%02x:%02x:%02x"

such defines should exist already in ieee80211 headers.

> -       /* Update our wireless stats, but do not schedule to often: 
> +       /* Update our wireless stats, but do not schedule to often : 

You could have fixed to->too while at it :)

> -       range->encoding_size[0] = 5;: 
> +       range->encoding_size[0] = KEY_SIZE_WEP40;: 
>         /* 128(104) bits WEP */
> -       range->encoding_size[1] = 13;: 
> +       range->encoding_size[1] = WEP_KEY_LEN;: 
>         /* 256 bits for WPA-PSK */
> -       range->encoding_size[2] = 32;: 
> +       range->encoding_size[2] = SCM_KEY_LEN;: 

Are there no constants for these in the ieee80211 headers? These look
home-grown.

> +               attach->type = DOT11_PKT_BEACON;: 

> +               attach->type = DOT11_PKT_PROBE_RESP;: 

These also look home-grown.


> -                        "%s %s %2.2X: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X %s (%2.2X)",
> +                        "%s %s %2.2X: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X [%2.2x %2.2X %4.4X]",
>                          str,
>                          ((priv->iw_mode == IW_MODE_MASTER) ? "from" : "to"),
>                          a[0], a[1], a[2], a[3], a[4], a[5],

Umm...

johannes
