From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Wed, 20 May 2015 13:59:05 -0700
Message-ID: <CAHA+R7MO1H8kCqwGd4dcEMJOB0D=qUdYkKq1K1Mmc5jJAQVikw@mail.gmail.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	<3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37777 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbETU7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 16:59:06 -0400
Received: by wibt6 with SMTP id t6so73664652wib.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 13:59:05 -0700 (PDT)
In-Reply-To: <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 8:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> -static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
> -                              size_t size, int flags)
> +struct unix_stream_read_state {
> +       int (*recv_actor)(struct sk_buff *, int, int,
> +                         struct unix_stream_read_state *);
> +       struct socket *socket;
> +       struct msghdr *msg;
> +       struct pipe_inode_info *pipe;
> +       size_t size;
> +       int flags;
> +       unsigned int splice_flags;
> +};
> +
> +static __always_inline
> +int unix_stream_read_generic(struct unix_stream_read_state *state)


Why __always_inline here?
