From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 20:43:48 +0800
Message-ID: <20081011124348.GA6845@gondor.apana.org.au>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37829 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752531AbYJKMny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 08:43:54 -0400
Content-Disposition: inline
In-Reply-To: <20081011103935.GA6168@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 06:39:35PM +0800, Herbert Xu wrote:
> 
> I think this should be done in iproute.  That way the user (or
> rather the user-space programmer) gets to choose the behaviour.
> This is also how the existing interface works too.

But there is a stupid bug in my code that causes garbage to
show up in the configuration.

gre: Initialise rtnl_link tunnel parameters properly

Brown paper bag error of calling memset with sizeof(p) instead
of sizeof(*p).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0d5e35b..482abda 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1345,7 +1345,7 @@ out:
 static void ipgre_netlink_parms(struct nlattr *data[],
 				struct ip_tunnel_parm *parms)
 {
-	memset(parms, 0, sizeof(parms));
+	memset(parms, 0, sizeof(*parms));
 
 	parms->iph.protocol = IPPROTO_GRE;
 
