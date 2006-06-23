From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel Janitor TODO: dev_kfree_skb
Date: Sat, 24 Jun 2006 09:47:08 +1000
Message-ID: <E1FtvMi-0001gp-00@gondolin.me.apana.org.au>
References: <449C2679.6020501@osdl.org>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57097 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1752177AbWFWXrW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 19:47:22 -0400
To: jdaiker@osdl.org (John Daiker)
In-Reply-To: <449C2679.6020501@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Daiker <jdaiker@osdl.org> wrote:
> 
> The "Balancing Function" header suggests that all net_device interrupt 
> functions should use dev_kfree_skb_irq as opposed to dev_kfree_skb.
> Should we ever be calling dev_kfree_skb directly, or would the better 
> practice be to always call dev_kfree_skb_any (thus letting the kernel 
> decide to call dev_kfree_skb or dev_kfree_skb_irq)?

It's best if you write code in a way so that you always know whether it's
IRQ context or not.  You should only use dev_kfree_skb_any when you fail
to write code like that.

Now once you've achieved that, then the next objective is to strive to
not have to call kfree_skb in IRQ context at all.  Have a look at the TG3
driver for an example where IRQ context is kept to a minimum.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
