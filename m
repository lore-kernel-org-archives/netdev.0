From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH]: Fix sk_buff page offsets and lengths.
Date: Tue, 31 Jul 2007 14:20:51 +0400
Message-ID: <20070731102050.GB30330@2ka.mipt.ru>
References: <20070730.185028.26532012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41138 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbXGaKVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 06:21:36 -0400
Content-Disposition: inline
In-Reply-To: <20070730.185028.26532012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 30, 2007 at 06:50:28PM -0700, David Miller (davem@davemloft.net) wrote:
> 
> Stephen Rothwell pointed out to me that the skb_frag_struct
> is broken on platforms using 64K or larger page sizes, it
> even generates warnings when (for example) the myri10ge driver
> tries to assign PAGE_SIZE into frag->size.
> 
> I've thus increased page offset and size to __u32 in the patch below.

Maybe wrap it into 
#if PAGE_OFFSET > 12
#endif

or something like that?

I'm not sure actually why drivers would want to have list of 64k pages,
instead driver could call give_me_pages(size) instead of alloc_pages 
and per-arch allocator would return one page or set of pages. This is a
handwaving for now...

-- 
	Evgeniy Polyakov
