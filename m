From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 1/3] net: Fix skb_copy_datagram_from_iovec()
	to pass the right offset
Date: Sun, 7 Jun 2009 00:25:33 +0300
Message-ID: <20090606212533.GD28614@redhat.com>
References: <1244230540.1526.76.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59782 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbZFFV02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2009 17:26:28 -0400
Content-Disposition: inline
In-Reply-To: <1244230540.1526.76.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 12:35:40PM -0700, Sridhar Samudrala wrote:
> I am working on enabling UFO between KVM guests using virtio-net and i have 
> some patches that i got working with 2.6.30-rc8. When i wanted to try them
> with net-next-2.6, i noticed that virtio-net is not working with that tree.
> 
> After some debugging, it turned out to be several bugs in the recent patches
> to fix aio with tun driver, specifically the following 2 commits.
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=0a1ec07a67bd8b0033dace237249654d015efa21
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=6f26c9a7555e5bcca3560919db9b852015077dae
> 
> 
> Fix the call to memcpy_from_iovecend() in skb_copy_datagram_from_iovec
> to pass the right iovec offset.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Yes, looks like the bugs were around GSO handling, I was probably
testing without GSO at the time. I'll go try with GSO now. Thanks for
fixing these!

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> diff --git a/net/core/datagram.c b/net/core/datagram.c
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -466,7 +466,8 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
>  	if (copy > 0) {
>  		if (copy > len)
>  			copy = len;
> -		if (memcpy_fromiovecend(skb->data + offset, from, 0, copy))
> +		if (memcpy_fromiovecend(skb->data + offset, from, from_offset,
> +					copy))
>  			goto fault;
>  		if ((len -= copy) == 0)
>  			return 0;
> 

-- 
MST
