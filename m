From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [2.6 PATCH] bridge - provide valid tos value for ip_route_output_key
Date: Wed, 3 Dec 2003 19:38:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312031938.22925.bdschuym@pandora.be>
References: <Pine.LNX.4.44.0312030156410.1237-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0312030156410.1237-200000@u.domain.uli>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave, If you haven't already applied the patch from Julian Anastasov
below, please do.

cheers,
Bart

On Wednesday 03 December 2003 01:03, Julian Anastasov wrote:
> 	The attached patch changes bridging to provide valid
> tos value to routing.


diff -Nru a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c	Tue Dec  2 23:55:30 2003
+++ b/net/bridge/br_netfilter.c	Tue Dec  2 23:55:30 2003
@@ -180,7 +180,7 @@
 			struct rtable *rt;
 			struct flowi fl = { .nl_u = 
 			{ .ip4_u = { .daddr = iph->daddr, .saddr = 0 ,
-				     .tos = iph->tos} }, .proto = 0};
+				     .tos = RT_TOS(iph->tos)} }, .proto = 0};
 
 			if (!ip_route_output_key(&rt, &fl)) {
 				/* Bridged-and-DNAT'ed traffic doesn't
