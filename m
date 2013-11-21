From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen
 logic
Date: Thu, 21 Nov 2013 07:00:14 -0800
Message-ID: <1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131121003828.GA32587@order.stressinduktion.org>
	 <528E1E2E.20905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:60883 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913Ab3KUPAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 10:00:20 -0500
Received: by mail-pa0-f50.google.com with SMTP id kl14so1126529pab.23
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 07:00:18 -0800 (PST)
In-Reply-To: <528E1E2E.20905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 09:52 -0500, Vlad Yasevich wrote:
> On 11/20/2013 07:38 PM, Hannes Frederic Sowa wrote:
> > diff --git a/include/linux/net.h b/include/linux/net.h
> > index b292a04..4bcee94 100644
> > --- a/include/linux/net.h
> > +++ b/include/linux/net.h
> > @@ -164,6 +164,14 @@ struct proto_ops {
> >  #endif
> >  	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
> >  				      struct msghdr *m, size_t total_len);
> > +	/* Notes for implementing recvmsg:
> > +	 * ===============================
> > +	 * msg->msg_namelen should get updated by the recvmsg handlers
> > +	 * iff msg_name != NULL. It is by default 0 to prevent
> > +	 * returning uninitialized memory to user space.  The recvfrom
> > +	 * handlers can assume that msg.msg_name is either NULL or has
> > +	 * a minimum size of sizeof(struct sockaddr_storage).
>              ^^^^^^^
> 
> You meant "maximum", right?

He meant : A protocol can safely assume there are sizeof(struct
sockaddr_storage) bytes available.

So a protocol should use BUILD_BUG_ON() to make sure sockaddr_storage is
big enough.
