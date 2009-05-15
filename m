From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/5] sit: Fail to create tunnel, if it already exists,
Date: Fri, 15 May 2009 15:30:08 +0200
Message-ID: <20090515133007.GK25620@psychotron.englab.brq.redhat.com>
References: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sascha Hlusiak <contact@saschahlusiak.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59481 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbZEONaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 09:30:15 -0400
Content-Disposition: inline
In-Reply-To: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 15, 2009 at 02:52:47PM CEST, contact@saschahlusiak.de wrote:
>When locating the tunnel, do not continue if it is found. Otherwise
>a different tunnel with similar configuration would be returned and
>parts could be overwritten.

You are missing Signed-off-by line in the whole patchset.

>---
> net/ipv6/sit.c |    7 +++++--
> 1 files changed, 5 insertions(+), 2 deletions(-)
>
>diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
>index 664ab82..bd63a7e 100644
>--- a/net/ipv6/sit.c
>+++ b/net/ipv6/sit.c
>@@ -165,8 +165,13 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
> 	struct sit_net *sitn = net_generic(net, sit_net_id);
> 
> 	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
>-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
>-			return t;
>+		if (local == t->parms.iph.saddr &&
>+		    remote == t->parms.iph.daddr) {
>+			if (create)
>+				return NULL;
>+			else
>+				return t;
>+		}
> 	}
> 	if (!create)
> 		goto failed;
>-- 
>1.6.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
