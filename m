From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Tue, 16 Dec 2003 22:46:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312162246.45994.bdschuym@pandora.be>
References: <Pine.LNX.4.44.0312160859290.16778-100000@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.44.0312160859290.16778-100000@sorbus2.navaho>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 16 December 2003 10:00, Steve Hill wrote:
> On Tue, 16 Dec 2003, Bart De Schuymer wrote:
> > Steve, does this patch fix things? Of course, first remove your code from
> > ip_fragment.c. I haven't tested this patch yet, this will have to wait
> > until this evening.
>
> No, it still leaks I'm afraid :(

OK, I think the patch below should fix it, my previous patch is still valid.
I'll send a combined patch once it's confirmed this fixes the bug.

Steve, please test this patch.

cheers,
Bart

--- linux-2.6.0-test11-bk10/net/ipv4/ip_output.c.old	2003-12-16 22:05:02.000000000 +0100
+++ linux-2.6.0-test11-bk10/net/ipv4/ip_output.c	2003-12-16 22:36:02.000000000 +0100
@@ -417,6 +417,7 @@ static void ip_copy_metadata(struct sk_b
 	to->nfct = from->nfct;
 	nf_conntrack_get(to->nfct);
 #ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_put(to->nf_bridge);
 	to->nf_bridge = from->nf_bridge;
 	nf_bridge_get(to->nf_bridge);
 #endif
