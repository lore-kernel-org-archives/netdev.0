From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Is it a possible bug in dev_gro_receive()?
Date: Mon, 2 Aug 2010 19:04:27 +0800
Message-ID: <20100802110427.GA9494@gondor.apana.org.au>
References: <1280454855-7893-1-git-send-email-xiaohui.xin@intel.com> <20100802102906.GA8439@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Xiaohui <xiaohui.xin@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:32772 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab0HBLEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 07:04:33 -0400
Content-Disposition: inline
In-Reply-To: <20100802102906.GA8439@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 02, 2010 at 10:29:06AM +0000, Jarek Poplawski wrote:
> Xin Xiaohui wrote:
> > I looked into the code dev_gro_receive(), found the code here:
> > if the frags[0] is pulled to 0, then the page will be released,
> > and memmove() frags left.
> > Is that right? I'm not sure if memmove do right or not, but
> > frags[0].size is never set after memove at least. what I think
> > a simple way is not to do anything if we found frags[0].size == 0.
> > The patch is as followed.
> > 
> > Or am I missing something here?
> 
> I think, you're right, but fixing memmove looks nicer to me:
> 
>  -	--skb_shinfo(skb)->nr_frags);
>  +	--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));

I agree with the diagnosis and your proposed fix.

Thanks for catching this Xiaohui!

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
