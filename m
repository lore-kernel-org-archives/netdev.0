From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 13:28:52 +0000
Message-ID: <20100127132852.GC15611@ff.dom.local>
References: <20100127121746.GA15611@ff.dom.local> <20100127.042336.52877358.davem@davemloft.net> <20100127124331.GB15611@ff.dom.local> <20100127.051410.74328462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:60196 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0A0N26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 08:28:58 -0500
Received: by fxm20 with SMTP id 20so1563895fxm.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 05:28:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100127.051410.74328462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 05:14:10AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Jan 2010 12:43:31 +0000
> 
> > I'm only not sure there is a better way (comments?) to make this
> > code readable.
> 
> You can make it more readable and even validate the invariant at the
> same time by adding some kind of inline function if you wish.
> 
> static inline struct dst_entry *rtable_to_dst_entry(struct rtable *rt)
> {
> 	BUILD_BUG_ON(rt != &rt->u.dst);
> 
> 	/* Because "->u.dst" is the first member of struct rtable,
> 	 * this dereference is safe even when rt is NULL.
> 	 */
> 	return &rt->u.dst;
> }
> 
> Something like that.

Yes, it looks the most readable to me.

Thanks,
Jarek P.
