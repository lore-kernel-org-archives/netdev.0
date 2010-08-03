From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] deal with if frags[0].size is pulled to 0 in
 dev_gro_receive()
Date: Mon, 02 Aug 2010 22:03:58 -0700 (PDT)
Message-ID: <20100802.220358.186311045.davem@davemloft.net>
References: <1280805439-18988-1-git-send-email-xiaohui.xin@intel.com>
	<20100803045637.GA14173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755006Ab0HCFDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:03:40 -0400
In-Reply-To: <20100803045637.GA14173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 3 Aug 2010 12:56:38 +0800

> On Tue, Aug 03, 2010 at 11:17:19AM +0800, xiaohui.xin@intel.com wrote:
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>> 
>> Now in dev_gro_receive(), if frags[0].size is pulled to 0, memmove is called and
>> the null page is released. But it's not enough, we should reset size of each frags
>> left as well. Compared to this, we can have another way to do this, it's not do do
>> anything at all.
>> 
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> 
> This patch can only work if you audit everything that uses skb
> frags to ensure that they can tolerate a zero-sided frag.
> 
> I think it's much easier to just fix the memmove.

Agreed.
