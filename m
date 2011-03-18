From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 16572] random panics in bridging on 2.6.34+
Date: Fri, 18 Mar 2011 10:27:28 -0500
Message-ID: <20110318152728.GA22053@gondor.apana.org.au>
References: <bug-16572-100@https.bugzilla.kernel.org/> <201103181349.p2IDn3Qm024329@demeter2.kernel.org> <20110318081052.6ca134fb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugzilla-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38818 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab1CRP1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 11:27:35 -0400
Content-Disposition: inline
In-Reply-To: <20110318081052.6ca134fb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 08:10:52AM -0700, Stephen Hemminger wrote:
> On Fri, 18 Mar 2011 13:49:03 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=16572
>
> Herbert hasn't submitted the patch upstream.

Oops! Thanks for reminding me.

bridge: Reset IPCB when entering IP stack on NF_FORWARD

Whenever we enter the IP stack proper from bridge netfilter we
need to ensure that the skb is in a form the IP stack expects
it to be in.

The entry point on NF_FORWARD did not meet the requirements of
the IP stack, therefore leading to potential crashes/panics.

This patch fixes the problem.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 865fd76..7e9b167 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -752,6 +752,9 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
+	if (br_parse_ip_options(skb))
+		return NF_DROP;
+
 	/* The physdev module checks on this */
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
