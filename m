From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Thu, 20 Mar 2008 08:30:17 -0700
Message-ID: <20080320153017.GA2106@linuxace.com>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com> <47DF7511.5080502@openvz.org> <47DF9099.30701@openvz.org> <20080320003917.GA9198@linuxace.com> <47E2790A.9040206@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:38981
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756332AbYCTPaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 11:30:20 -0400
Content-Disposition: inline
In-Reply-To: <47E2790A.9040206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Mar 20, 2008 at 03:47:38PM +0100, Patrick McHardy wrote:
> >And it has survived 1.5 days without issue.  Patrick - will you be pushing
> >to David?
> 
> Could you send the patch you've been using?

Sure - attached below against current git.  I assume you will add your
signoff, but you can add

Tested-by: Phil Oester <kernel@linuxace.com>

Phil



--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-ipfrags

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a2e92f9..3b2e5ad 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -568,7 +568,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
 
-	net = skb->dev->nd_net;
+	net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
 		ip_evictor(net);

--1yeeQ81UyVL57Vl7--
