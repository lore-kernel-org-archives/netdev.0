From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH] fix bridge-nf with IP defragmentation
Date: Sun, 21 Dec 2003 21:15:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312212115.10508.bdschuym@pandora.be>
References: <200312211258.36325.bdschuym@pandora.be> <20031221120239.16356d2c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031221120239.16356d2c.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 21 December 2003 21:02, David S. Miller wrote:
> Please make this relative to the previous patch which I already
> applied.

I thought you missed that patch.
The only difference is the change to ip6_output.c, which is right now
purely cosmetic since bridged ipv6 traffic isn't yet seen by ip6tables.
But it's best to do it now as it might be forgotten later...

cheers,
Bart

--- linux-2.6.0/net/ipv6/ip6_output.c.old	2003-12-21 12:52:26.000000000 +0100
+++ linux-2.6.0/net/ipv6/ip6_output.c	2003-12-21 12:52:38.000000000 +0100
@@ -877,6 +877,7 @@ static void ip6_copy_metadata(struct sk_
 	to->nfct = from->nfct;
 	nf_conntrack_get(to->nfct);
 #ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_put(to->nf_bridge);
 	to->nf_bridge = from->nf_bridge;
 	nf_bridge_get(to->nf_bridge);
 #endif
