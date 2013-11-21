From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen logic
Date: Thu, 21 Nov 2013 18:04:34 +0100
Message-ID: <20131121170434.GA6745@order.stressinduktion.org>
References: <20131121003828.GA32587@order.stressinduktion.org> <528E1E2E.20905@gmail.com> <1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57467 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab3KUREg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 12:04:36 -0500
Content-Disposition: inline
In-Reply-To: <1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 07:00:14AM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 09:52 -0500, Vlad Yasevich wrote:
> > On 11/20/2013 07:38 PM, Hannes Frederic Sowa wrote:
> > > diff --git a/include/linux/net.h b/include/linux/net.h
> > > index b292a04..4bcee94 100644
> > > --- a/include/linux/net.h
> > > +++ b/include/linux/net.h
> > > @@ -164,6 +164,14 @@ struct proto_ops {
> > >  #endif
> > >  	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
> > >  				      struct msghdr *m, size_t total_len);
> > > +	/* Notes for implementing recvmsg:
> > > +	 * ===============================
> > > +	 * msg->msg_namelen should get updated by the recvmsg handlers
> > > +	 * iff msg_name != NULL. It is by default 0 to prevent
> > > +	 * returning uninitialized memory to user space.  The recvfrom
> > > +	 * handlers can assume that msg.msg_name is either NULL or has
> > > +	 * a minimum size of sizeof(struct sockaddr_storage).
> >              ^^^^^^^
> > 
> > You meant "maximum", right?
> 
> He meant : A protocol can safely assume there are sizeof(struct
> sockaddr_storage) bytes available.

Yes, exactly. Apparently it seems to does cause confusion as I wrote it. Maybe I should
reword it?
