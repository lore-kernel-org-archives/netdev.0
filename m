From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Wed, 1 Jun 2016 11:42:18 +0800
Message-ID: <20160601034218.GA31335@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au>
 <20160531.140713.2187659962450926738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56617 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676AbcFADma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 23:42:30 -0400
Content-Disposition: inline
In-Reply-To: <20160531.140713.2187659962450926738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 02:07:13PM -0700, David Miller wrote:
> 
> I think you need to set the vlan->port->mc_filter to all 1's in the
> PROMISC/ALLMUTI branch here.
> 
> Otherwise packets won't properly pass your new hash test.

Good point.  Here's v2.

This patch tries to improve macvlan multicast performance by
maintaining a filter hash at the macvlan_port level so that we
can quickly determine whether a given packet is needed or not.

It is preceded by a patch that fixes a potential use-after-free
bug that I discovered while looking over this.

v2 fixed a bug where promiscuous/allmulti settings weren't handled
correctly.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
