From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to
 void
Date: Wed, 06 May 2015 09:14:47 -0700
Message-ID: <1430928887.9365.90.camel@perches.com>
References: <cover.1430769294.git.joe@perches.com>
	 <1430771550.2872.7.camel@perches.com>
	 <20150505.192003.2226565044238098170.davem@davemloft.net>
	 <1430869128.9365.67.camel@perches.com>
	 <1430914779.14545.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0026.hostedemail.com ([216.40.44.26]:34826 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751303AbbEFQOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:14:50 -0400
In-Reply-To: <1430914779.14545.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-06 at 05:19 -0700, Eric Dumazet wrote:
> On Tue, 2015-05-05 at 16:38 -0700, Joe Perches wrote:
> > Another thing that's fairly common is an skb_put followed by
> > a memcpy or memset.
> > Adding a couple of functions for those like:
> > void *skb_put_memcpy(struct sk_buff *skb, void *from, size_t size);
> > void *skb_put_memset(struct sk_buff *skb, int c, size_t size);
> > would reduce code size and improve performance a little.

[]

> We understand the code as is, with regular memcpy() and memset()
> These functions are fine. They were fine 20 years ago, nothing changed.

Prefer speed and size improvements over stasis.

alloc+memset works, zalloc exists.

Using these functions would reduce a non-modular defconfig
x86-64 net/built-in.o by a couple kb.

Probably double that for a kernel.

These functions would be used in the packet processing path
for wireless too.
