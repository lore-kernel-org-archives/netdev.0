From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Performance loss due to commit  37c3185 ([NET]: Added GSO toggle)
Date: Thu, 25 Jun 2015 22:37:08 +0800
Message-ID: <20150625143708.GA10700@gondor.apana.org.au>
References: <55853877.9080000@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: christophe leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59300 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbFYOhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 10:37:14 -0400
Content-Disposition: inline
In-Reply-To: <55853877.9080000@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 11:55:03AM +0200, christophe leroy wrote:
> Hello Herbert,
> 
> In commit "[NET]: Added GSO toggle"
> 37c3185a02d4b85fbe134bf5204535405dd2c957,
> you force NETIF_F_HW_CSUM if GSO feature is selected.
> By default, SW GSO is active as soon as a network board has NETIF_F_SG
> feature.
> This means that function sk_setup_caps() forces NETIF_F_HW_CSUM for any
> board having NETIF_F_SG
> 
> For boards having no HW checksum capability, this results in performance
> loss due to data copy being done in skb_do_copy_data_nocache() with
> copy_from_user() then checksum being done later with csum_partial()
> instead of getting both done at the same time using
> csum_and_copy_from_user()
> 
> Is there a reason for forcing NETIF_F_HW_CSUM   ?

Well GSO requires hardware checksum for all the protocols that
it supports.  I guess we should also check that the hardware can
checksum both IPv4 and IPv6 before enabling it.

However, the benefit of GSO should cancel out the cost of copying
so I was hoping to just enable GSO unconditionally at some point.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
