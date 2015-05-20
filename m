From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Wed, 20 May 2015 16:50:58 -0700
Message-ID: <1432165858.4060.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	 <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:34330 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbbETXvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:51:00 -0400
Received: by ieczm2 with SMTP id zm2so51630175iec.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 16:50:59 -0700 (PDT)
In-Reply-To: <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 17:35 +0200, Hannes Frederic Sowa wrote:

> +
> +static int unix_stream_splice_actor(struct sk_buff *skb,
> +				    int skip, int chunk,
> +				    struct unix_stream_read_state *state)
> +{
> +	return skb_splice_bits(skb, state->socket->sk,
> +			       UNIXCB(skb).consumed + skip,
> +			       state->pipe, chunk, state->splice_flags,
> +			       skb_unix_socket_splice);
> +}

I am not sure you added EXPORT_SYMBOL(skb_splice_bits) in one of the
patches ?

Make sure CONFIG_UNIX=m still works.

Thanks.
