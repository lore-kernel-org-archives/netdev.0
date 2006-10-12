From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sotftmac: fix a slab corruption in WEP restricted key
 association
Date: Wed, 11 Oct 2006 20:34:11 -0400
Message-ID: <452D8D83.60908@gentoo.org>
References: <452D6D80.3020005@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.iad.emailsrvr.com ([207.97.245.121]:38021 "EHLO
	smtp121.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1030211AbWJLAex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 20:34:53 -0400
To: Laurent Riffard <laurent.riffard@free.fr>
In-Reply-To: <452D6D80.3020005@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Riffard wrote:
> Fix a slab corruption in ieee80211softmac_auth(). The size of a buffer
> was miscomputed.
> 
> see http://bugzilla.kernel.org/show_bug.cgi?id=7245
> 
> Acked-by: Daniel Drake <dsd@gentoo.org>"
> Signed-off-by: Laurent Riffard <laurent.riffard@free.fr>

Apparently the CC list didn't work out. Adding Johannes and netdev.

> net/ieee80211/softmac/ieee80211softmac_io.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6-mm/net/ieee80211/softmac/ieee80211softmac_io.c
> ===================================================================
> --- linux-2.6-mm.orig/net/ieee80211/softmac/ieee80211softmac_io.c
> +++ linux-2.6-mm/net/ieee80211/softmac/ieee80211softmac_io.c
> @@ -304,7 +304,7 @@ ieee80211softmac_auth(struct ieee80211_a
>         2 +        /* Auth Transaction Seq */
>         2 +        /* Status Code */
>          /* Challenge Text IE */
> -        is_shared_response ? 0 : 1 + 1 + net->challenge_len
> +        (is_shared_response ? 1 + 1 + net->challenge_len : 0)
>     );
>     if (unlikely((*pkt) == NULL))
>         return 0;
> 

