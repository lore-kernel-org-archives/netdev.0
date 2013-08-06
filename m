From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: cubic: fix bug in bictcp_acked()
Date: Tue, 6 Aug 2013 09:49:44 -0400
Message-ID: <CADVnQympGLkaYVAfac5QkALYCHO2D=h_+yVe3MYwirg9EhapHQ@mail.gmail.com>
References: <1375758312.4457.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:42389 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301Ab3HFNtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 09:49:46 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so232172eak.15
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 06:49:45 -0700 (PDT)
In-Reply-To: <1375758312.4457.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 5, 2013 at 11:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While investigating about strange increase of retransmit rates
> on hosts ~24 days after boot, Van found hystart was disabled
> if ca->epoch_start was 0, as following condition is true
> when tcp_time_stamp high order bit is set.
>
> (s32)(tcp_time_stamp - ca->epoch_start) < HZ
>
> Quoting Van :
>
>  At initialization & after every loss ca->epoch_start is set to zero so
>  I believe that the above line will turn off hystart as soon as the 2^31
>  bit is set in tcp_time_stamp & hystart will stay off for 24 days.
>  I think we've observed that cubic's restart is too aggressive without
>  hystart so this might account for the higher drop rate we observe.
>
> Diagnosed-by: Van Jacobson <vanj@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Nice catch!

neal
