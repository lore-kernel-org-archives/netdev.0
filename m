From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] deal with if frags[0].size is pulled to 0 in
	dev_gro_receive()
Date: Tue, 3 Aug 2010 12:56:38 +0800
Message-ID: <20100803045637.GA14173@gondor.apana.org.au>
References: <1280805439-18988-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57789 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab0HCE4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:56:40 -0400
Content-Disposition: inline
In-Reply-To: <1280805439-18988-1-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 03, 2010 at 11:17:19AM +0800, xiaohui.xin@intel.com wrote:
> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
> Now in dev_gro_receive(), if frags[0].size is pulled to 0, memmove is called and
> the null page is released. But it's not enough, we should reset size of each frags
> left as well. Compared to this, we can have another way to do this, it's not do do
> anything at all.
> 
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>

This patch can only work if you audit everything that uses skb
frags to ensure that they can tolerate a zero-sided frag.

I think it's much easier to just fix the memmove.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
