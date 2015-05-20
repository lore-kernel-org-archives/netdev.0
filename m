From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Thu, 21 May 2015 01:57:07 +0200
Message-ID: <1432166227.744955.274295553.7D5DAD76@webmail.messagingengine.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
 <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
 <1432165858.4060.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34078 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752759AbbETX5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:57:08 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 777E4208BF
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 19:57:07 -0400 (EDT)
In-Reply-To: <1432165858.4060.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015, at 01:50, Eric Dumazet wrote:
> On Wed, 2015-05-20 at 17:35 +0200, Hannes Frederic Sowa wrote:
> 
> > +
> > +static int unix_stream_splice_actor(struct sk_buff *skb,
> > +				    int skip, int chunk,
> > +				    struct unix_stream_read_state *state)
> > +{
> > +	return skb_splice_bits(skb, state->socket->sk,
> > +			       UNIXCB(skb).consumed + skip,
> > +			       state->pipe, chunk, state->splice_flags,
> > +			       skb_unix_socket_splice);
> > +}
> 
> I am not sure you added EXPORT_SYMBOL(skb_splice_bits) in one of the
> patches ?
> 
> Make sure CONFIG_UNIX=m still works.

I didn't. Thanks, I will test that.

Bye,
Hannes
