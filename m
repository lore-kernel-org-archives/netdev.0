From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4] net: ipv6: fix code style error and warning
 of ndisc.c
Date: Sat, 20 May 2017 07:55:56 -0700
Message-ID: <1495292156.2093.5.camel@perches.com>
References: <1495288650-17072-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0186.hostedemail.com ([216.40.44.186]:43899 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752621AbdETO4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 10:56:00 -0400
In-Reply-To: <1495288650-17072-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-05-20 at 21:57 +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
[]
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
[]
> @@ -240,13 +240,15 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
>  					  "%s: duplicated ND6 option found: type=%d\n",
>  					  __func__, nd_opt->nd_opt_type);
>  			} else {
> -				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
> +					nd_opt;
>  			}
>  			break;
>  		case ND_OPT_PREFIX_INFO:
>  			ndopts->nd_opts_pi_end = nd_opt;
>  			if (!ndopts->nd_opt_array[nd_opt->nd_opt_type])
> -				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
> +					nd_opt;
>  			break;
>  #ifdef CONFIG_IPV6_ROUTE_INFO
>  		case ND_OPT_ROUTE_INFO:

If you are going to do these 80 column line length changes,
(and they are not really useful or necessary here), perhaps
it'd be better to use a temporary to reduce the line length.

Something like:
---
 net/ipv6/ndisc.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc41209a..a8521bc86795 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -234,20 +234,28 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 		case ND_OPT_TARGET_LL_ADDR:
 		case ND_OPT_MTU:
 		case ND_OPT_NONCE:
-		case ND_OPT_REDIRECT_HDR:
-			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
+		case ND_OPT_REDIRECT_HDR: {
+			struct nd_opt_hdr **hdr;
+
+			hdr = &ndopts->nd_opt_array[nd_opt->nd_opt_type];
+			if (*hdr) {
 				ND_PRINTK(2, warn,
 					  "%s: duplicated ND6 option found: type=%d\n",
 					  __func__, nd_opt->nd_opt_type);
 			} else {
-				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
+				*hdr = nd_opt;
 			}
 			break;
-		case ND_OPT_PREFIX_INFO:
+		}
+		case ND_OPT_PREFIX_INFO: {
+			struct nd_opt_hdr **hdr;
+
+			hdr = &ndopts->nd_opt_array[nd_opt->nd_opt_type];
 			ndopts->nd_opts_pi_end = nd_opt;
-			if (!ndopts->nd_opt_array[nd_opt->nd_opt_type])
-				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
+			if (!*hdr)
+				*hdr = nd_opt;
 			break;
+		}
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		case ND_OPT_ROUTE_INFO:
 			ndopts->nd_opts_ri_end = nd_opt;
