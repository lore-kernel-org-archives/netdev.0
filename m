From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix TX bug VLAN in VLAN
Date: Tue, 27 Nov 2007 14:38:59 +0800
Message-ID: <20071127063859.GB2942@gondor.apana.org.au>
References: <003f01c82dca$305acd40$9c94fea9@jason> <20071126112631.GA26599@gondor.apana.org.au> <b25c3fa70711262132r3f88db02mcede6d14b82d5fc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, tristan_schmelcher@alumni.uwaterloo.ca,
	acme@ghostprotocols.net
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4135 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750730AbXK0GjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 01:39:16 -0500
Content-Disposition: inline
In-Reply-To: <b25c3fa70711262132r3f88db02mcede6d14b82d5fc0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 02:32:49PM +0900, Joonwoo Park wrote:
> 
> Thanks Herbert.
> Well.. I think patch would work propely for AF_PACKET also.
> (I did not insert BUG() macro in my patch)
> How do you think?

Are you sure? I thought you need to check both in the xmit function.
That is,

	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
	    VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR) {

Otherwise you'll miss AF_PACKET packets when REORDER is off.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
