From: Julian Anastasov <ja@ssi.bg>
Subject: xfrm_neigh_lookup and dst->path
Date: Sat, 11 Feb 2017 15:12:44 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702111354440.1601@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51275 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753198AbdBKNMv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Feb 2017 08:12:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 3 Feb 2017, Steffen Klassert wrote:

> On Thu, Feb 02, 2017 at 01:04:34AM +0200, Julian Anastasov wrote:
> > 
> > 	For now I installed common handler, just like
> > xfrm_neigh_lookup. BTW this function has problem from
> > commit f894cbf847c9, it looks like dst is wrongly provided,
> > first arg should be dst->path.
> 
> Yes, this should use dst->path of course. I really wonder why
> nobody noticed this for the last five years.

	IMHO, xfrm_neigh_lookup is not used often. If used,
it should be from a place before skb->dst xforms are popped in
xfrm_output_one, i.e. somewhere before the output processing.
I see that dst_neigh_lookup*() is used mostly in xmit handlers
of tunnel devices, I assume, after xfrm_output_one().
Not sure for br_nf_pre_routing_finish_bridge().

	I'm trying to fix this code but we have the
same problem as in xfrm_confirm_neigh: to find address
of last tunnel. Should we use the same loop?

Regards
