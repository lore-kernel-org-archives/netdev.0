From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH] xfrm: fix a race in xfrm_state_lookup_byspi
Date: Wed, 29 Apr 2015 05:25:25 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848E4D693@SHSMSX104.ccr.corp.intel.com>
References: <1430268164-19019-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"Du, Fan" <fan.du@intel.com>
To: "roy.qing.li@gmail.com" <roy.qing.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40041 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751518AbbD2FZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 01:25:30 -0400
In-Reply-To: <1430268164-19019-1-git-send-email-roy.qing.li@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: roy.qing.li@gmail.com [mailto:roy.qing.li@gmail.com]
>Sent: Wednesday, April 29, 2015 8:43 AM
>To: netdev@vger.kernel.org
>Cc: Du, Fan; steffen.klassert@secunet.com
>Subject: [PATCH] xfrm: fix a race in xfrm_state_lookup_byspi
>
>From: Li RongQing <roy.qing.li@gmail.com>
>
>The returned xfrm_state should be hold before unlock xfrm_state_lock,
>otherwise the returned xfrm_state maybe be released.
>
>Fixes: c454997e6[{pktgen, xfrm} Introduce xfrm_state_lookup_byspi..]
>Cc: Fan Du <fan.du@intel.com>
>Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Fan Du <fan.du@intel.com>
 

>---
> net/xfrm/xfrm_state.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
>index f5e39e3..96688cd 100644
>--- a/net/xfrm/xfrm_state.c
>+++ b/net/xfrm/xfrm_state.c
>@@ -927,8 +927,8 @@ struct xfrm_state *xfrm_state_lookup_byspi(struct net
>*net, __be32 spi,
> 			x->id.spi != spi)
> 			continue;
>
>-		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
> 		xfrm_state_hold(x);
>+		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
> 		return x;
> 	}
> 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
>--
>2.1.0
