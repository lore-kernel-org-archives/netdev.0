From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] net: rework recvmsg handler msg_name and msg_namelen logic
Date: Wed, 20 Nov 2013 06:37:04 +0100
Message-ID: <20131120053704.GU16541@order.stressinduktion.org>
References: <20131119052759.GR16541@order.stressinduktion.org> <20131119.154058.2058377571860676832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54111 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab3KTFhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 00:37:05 -0500
Content-Disposition: inline
In-Reply-To: <20131119.154058.2058377571860676832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 03:40:58PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 19 Nov 2013 06:27:59 +0100
> 
> > This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> > set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> > to return msg_name to the user.
> > 
> > This prevents numerous uninitialized memory leaks we had in the
> > recvmsg handlers and makes it harder for new code to accidentally leak
> > uninitialized memory.
> > 
> > Optimize for the case recvfrom is called with NULL as address. We don't
> > need to copy the address at all, so set it to NULL before invoking the
> > recvmsg handler. We can do so, because all the recvmsg handlers must
> > cope with the case a plain read() is called on them. read() also sets
> > msg_name to NULL.
> > 
> > Also document these changes in include/linux/net.h as suggested by David
> > Miller.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Looks good to me.
> 
> The only other invoker of ->recvmsg is vhost.c but it sets msg_name to NULL
> and msg_namelen to 0 so should be fine.

Thanks for the review!

I had no time to look after this change today. I want to make another
round of review tomorrow and will post a final version then.
