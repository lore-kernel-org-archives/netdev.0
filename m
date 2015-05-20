From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Wed, 20 May 2015 23:47:58 +0200
Message-ID: <1432158478.717952.274218561.54417CB3@webmail.messagingengine.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
 <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
 <CAHA+R7MO1H8kCqwGd4dcEMJOB0D=qUdYkKq1K1Mmc5jJAQVikw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57491 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753158AbbETVr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 17:47:58 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 3F07F20988
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 17:47:58 -0400 (EDT)
In-Reply-To: <CAHA+R7MO1H8kCqwGd4dcEMJOB0D=qUdYkKq1K1Mmc5jJAQVikw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Wed, May 20, 2015, at 22:59, Cong Wang wrote:
> On Wed, May 20, 2015 at 8:35 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >
> > -static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
> > -                              size_t size, int flags)
> > +struct unix_stream_read_state {
> > +       int (*recv_actor)(struct sk_buff *, int, int,
> > +                         struct unix_stream_read_state *);
> > +       struct socket *socket;
> > +       struct msghdr *msg;
> > +       struct pipe_inode_info *pipe;
> > +       size_t size;
> > +       int flags;
> > +       unsigned int splice_flags;
> > +};
> > +
> > +static __always_inline
> > +int unix_stream_read_generic(struct unix_stream_read_state *state)
> 
> 
> Why __always_inline here?

During benchmarking I discovered that the simple ordinary recvmsg case
lost a bit in performance because of the indirection. With
__always_inline -ing unix_stream_read_generic I got it to almost the
same numbers again as without the change. Thus I decided to leave it
there.

Also, thank you for your other feedback. I will address it soon after
letting the patches receiving a bit more feedback.

Thanks,
Hannes
