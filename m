From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: neigh_lookup lockdep bug.
Date: Wed, 02 Aug 2006 04:26:49 +0200
Message-ID: <1154485629.3030.21.camel@laptopd505.fenrus.org>
References: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-nvb.com ([69.27.17.200]:51399 "EHLO e-nvb.com")
	by vger.kernel.org with ESMTP id S1751068AbWHBC1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 22:27:12 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-01 at 23:19 +1000, Herbert Xu wrote:
> Arjan van de Ven <arjan@infradead.org> wrote:
> > 
> > we fixed lockdep to have this lock key to be per skb queue ... didn't
> > you put that patch in rawhide Dave (J) ?
> 
> I've only briefly looked at the lockdep_set_class code so I might be
> way off here.
> 
> It seems that for lockdep_set_class to work its second argument should
> be distinct for each class of locks that you wish to distinguish.  So
> shouldn't we be putting the key into struct sk_buff_head rather than
> having one key (skb_queue_lock_key) for all sk_buff_head's?
> 

fwiw the patch is at
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/lockdep-split-the-skb_queue_head_init-lock-class.patch
and a followup cleanup at
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/lockdep-split-the-skb_queue_head_init-lock-class-tidy.patch


