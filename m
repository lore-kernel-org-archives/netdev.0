From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sat, 15 Jul 2006 18:12:22 -0700 (PDT)
Message-ID: <20060715.181222.74751444.davem@davemloft.net>
References: <20060714.144855.62664893.davem@davemloft.net>
	<E1G1kCA-000533-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, guichaz@yahoo.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56470
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946062AbWGPBMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 21:12:10 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 15 Jul 2006 23:28:34 +1000

> At least this lets us get rid of a few other memsets :)
> 
> [IPV4]: Get rid of redundant IPCB->opts initialisation
> 
> Now that we always zero the IPCB->opts in ip_rcv, it is no longer
> necessary to do so before calling netif_rx for tunneled packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, good spotting :-)  I remember when we added those
things.

But I'm beginning to think that the onus of this may in fact fall upon
the devices, in fact.  Loopback is one of the few devices where the
control block might not be cleared out, due to uses in the output
path.  Devices predominantly provide a zero'd out control block in the
skb on packet receive.

And the memset() cases we're removing here with Herbert's
change are the other exceptional cases, such as tunnels that
decapsulate the IPV4 protocol.

Other opinions welcome...
