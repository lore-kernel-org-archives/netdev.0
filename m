From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix NULL deref in tcp_v4_send_ack()
Date: Thu, 21 Jan 2016 11:06:02 -0500
Message-ID: <CADVnQyk+8G6bkhh5g_JxqpeeCquMrVfwA9=otMfmhFSYtVZAjg@mail.gmail.com>
References: <1453392174.1223.363.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33117 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965429AbcAUQGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 11:06:04 -0500
Received: by mail-yk0-f181.google.com with SMTP id k129so53664634yke.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 08:06:03 -0800 (PST)
In-Reply-To: <1453392174.1223.363.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 11:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
...
> The problem here is the skb we provide to tcp_v4_send_ack() had to
> be parked in the backlog of a new TCP fastopen child because this child
> was owned by the user at the time an out of window packet arrived.
>
> Before queuing a packet, TCP has to set skb->dev to NULL as the device
> could disappear before packet is removed from the queue.
>
> Fix this issue by using the net pointer provided by the socket (being a
> timewait or a request socket).

Thanks, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
