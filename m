From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: FW: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous mode
Date: Fri, 16 Nov 2007 22:33:48 +0800
Message-ID: <20071116143348.GA10596@gondor.apana.org.au>
References: <006601c82846$b0f99eb0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, greearb@candelatech.com,
	'Patrick McHardy' <kaber@trash.net>, w@1wt.eu,
	cfriesen@nortel.com, djohnson+linux-kernel@sw.starentnetworks.com,
	e1000-devel@lists.sourceforge.net,
	"'Kok, Auke'" <auke-jan.h.kok@intel.com>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4026 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763845AbXKPOep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 09:34:45 -0500
Content-Disposition: inline
In-Reply-To: <006601c82846$b0f99eb0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2007 at 08:49:02PM +0900, Joonwoo Park wrote:
> 
> Not anymore about just e1000 :)
> I made an another patch with different approach which doesn't fix nic driver.
> In addition, this patch does disable all hw vlan acceleration features (rx, tx, filter) for promiscuous netdevice. (It makes
> possible tcpdump -i eth0 vlan)
> Actually, my previous patch did just disable filter for e1000, so we can't see vlan header of packet. (e1000 stripped off the
> header)
> I think this patch is much better than previous of mine.
> How do you think?

I don't like this :)

Let's not turn promiscuous mode into catch-all flag that disables
all optimisations that may interfere with tcpdump.  It should show
us all the packets by disabling any hardware filtering but that's it.

BTW, how does the VLAN TX acceleration work at all? It's using
skb->cb to carry the tags but then calls dev_queue_xmit.  Once
you do that packet schedulers can scribble all over skb->cb.

Also vlan_skb_recv should be moved out-of-line.  It's absolutely
humongous.  It'll generate tail-calls anyway so performance-wise
it's useless.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
