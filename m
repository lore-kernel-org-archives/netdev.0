From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 16:56:35 +0200
Message-ID: <1342796195.2626.7363.camel@edumazet-glaptop>
References: <1342762841.2626.5633.camel@edumazet-glaptop>
	 <CABrhC0kdw7Uv-67t7fFcfh-Pve1LsNAQ3HGnUmCOJVB7b0dUVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:32779 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2GTO4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 10:56:42 -0400
Received: by bkwj10 with SMTP id j10so3462507bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 07:56:41 -0700 (PDT)
In-Reply-To: <CABrhC0kdw7Uv-67t7fFcfh-Pve1LsNAQ3HGnUmCOJVB7b0dUVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 10:41 -0400, John Heffner wrote:
> It might be clearer to instead introduce a temporary variable to
> calculate the snd_cwnd change in the while loop.  That is:
> 
>         unsigned int snd_cwnd_delta = 0;
> ...
>         tp->snd_cwnd_cnt += cnt;
>         while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
>                 tp->snd_cwnd_cnt -= tp->snd_cwnd;
>                 snd_cwnd_delta++;
>         }
>         tp->snd_cwnd = min(tp->snd_cwnd + snd_cwnd_delta, tp->snd_cwnd_clamp);
> 

Good idea, thanks, I'll send a v2
