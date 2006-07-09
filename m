From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Sun, 9 Jul 2006 17:59:42 +0300
Message-ID: <84144f020607090759o176f35edg603a26cb9c752e6e@mail.gmail.com>
References: <20060709132446.GB29435@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:38188 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030215AbWGIO7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 10:59:43 -0400
Received: by ug-out-1314.google.com with SMTP id a2so3611525ugf
        for <netdev@vger.kernel.org>; Sun, 09 Jul 2006 07:59:42 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060709132446.GB29435@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/9/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> +struct kevent *kevent_alloc(gfp_t mask)
> +{
> +       struct kevent *k;
> +
> +       if (kevent_cache)
> +               k = kmem_cache_alloc(kevent_cache, mask);
> +       else
> +               k = kzalloc(sizeof(struct kevent), mask);
> +
> +       return k;
> +}

What's this for? Why would kevent_cache be NULL? Note that you can use
kmem_cache_zalloc() for fixed size allocations that need to be zeroed.

On 7/9/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> +
> +void kevent_free(struct kevent *k)
> +{
> +       memset(k, 0xab, sizeof(struct kevent));

Why is slab poisoning not sufficient?

> +       if (kevent_cache)
> +               kmem_cache_free(kevent_cache, k);
> +       else
> +               kfree(k);
> +}
