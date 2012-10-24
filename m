From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow configuration of the size of page in
 __netdev_alloc_frag
Date: Wed, 24 Oct 2012 18:43:20 +0200
Message-ID: <1351097000.6537.109.camel@edumazet-glaptop>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
	 <1351081703.6537.99.camel@edumazet-glaptop>
	 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
	 <1351085403.6537.102.camel@edumazet-glaptop>
	 <1351087326.18035.50.camel@zakaz.uk.xensource.com>
	 <1351092068.6537.107.camel@edumazet-glaptop>
	 <1351095739.18035.83.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58629 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427Ab2JXQn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 12:43:26 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so361804bkc.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 09:43:24 -0700 (PDT)
In-Reply-To: <1351095739.18035.83.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-24 at 17:22 +0100, Ian Campbell wrote:
> On Wed, 2012-10-24 at 16:21 +0100, Eric Dumazet wrote:

> > If you really have such problems, why locally generated TCP traffic
> > doesnt also have it ?
> 
> I think it does. The reason I noticed the original problem was that ssh
> to the machine was virtually (no pun intended) unusable.
> 
> > Your patch doesnt touch sk_page_frag_refill(), does it ?
> 
> That's right. It doesn't. When is (sk->sk_allocation & __GFP_WAIT) true?
> Is it possible I'm just not hitting that case?
> 

I hope not. GFP_KERNEL has __GFP_WAIT.

> Is it possible that this only affects certain traffic patterns (I only
> really tried ssh/scp and ping)? Or perhaps its just that the swiotlb is
> only broken in one corner case and not the other.

Could you try a netperf -t TCP_STREAM ?

Because ssh use small packets, and small TCP packets dont use frags but
skb->head.

You mentioned a 70% drop of performance, but what test have you used
exactly ?
