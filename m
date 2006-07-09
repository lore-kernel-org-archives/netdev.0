From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Sun, 9 Jul 2006 19:08:20 +0400
Message-ID: <20060709150819.GB15071@2ka.mipt.ru>
References: <20060709132446.GB29435@2ka.mipt.ru> <84144f020607090759o176f35edg603a26cb9c752e6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:6086 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161021AbWGIPIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 11:08:34 -0400
To: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Disposition: inline
In-Reply-To: <84144f020607090759o176f35edg603a26cb9c752e6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 09, 2006 at 05:59:42PM +0300, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> On 7/9/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >+struct kevent *kevent_alloc(gfp_t mask)
> >+{
> >+       struct kevent *k;
> >+
> >+       if (kevent_cache)
> >+               k = kmem_cache_alloc(kevent_cache, mask);
> >+       else
> >+               k = kzalloc(sizeof(struct kevent), mask);
> >+
> >+       return k;
> >+}
> 
> What's this for? Why would kevent_cache be NULL? Note that you can use
> kmem_cache_zalloc() for fixed size allocations that need to be zeroed.

It can work without cache at all, i.e. if cache creation fails.
Well, it can be removed of course, since it does not hurt anything.

> On 7/9/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >+
> >+void kevent_free(struct kevent *k)
> >+{
> >+       memset(k, 0xab, sizeof(struct kevent));
> 
> Why is slab poisoning not sufficient?

Since that pointer is always known to be poisoned no matter if kernel
debugging option is turned on or off.

-- 
	Evgeniy Polyakov
