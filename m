From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v1 0/5] TCP Wave
Date: Fri, 28 Jul 2017 22:33:33 -0700
Message-ID: <1501306413.1876.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Natale Patriciello <natale.patriciello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35982 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdG2Fdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 01:33:36 -0400
Received: by mail-wm0-f47.google.com with SMTP id t201so139897111wmt.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 22:33:36 -0700 (PDT)
In-Reply-To: <20170728195919.10099-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-07-28 at 21:59 +0200, Natale Patriciello wrote:
> Hi,
> We are working on a new TCP congestion control algorithm, aiming at satisfying
> new requirements coming from current networks. For instance, adaptation to
> bandwidth/delay changes (due to mobility, dynamic switching, handover), and
> optimal exploitation of very high link capacity and efficient transmission of
> small objects, irrespective of the underlying link characteristics.
> 
> TCP Wave (TCPW) replaces the window-based transmission paradigm of the standard
> TCP with a burst-based transmission, the ACK-clock scheduling with a
> self-managed timer and the RTT-based congestion control loop with an Ack-based
> Capacity and Congestion Estimation (ACCE) module. In non-technical words, it
> sends data down the stack when its internal timer expires, and the timing of
> the received ACKs contribute to updating this timer regularly.
> 
> We tried to add this new sender paradigm without deeply touching existing code.
> In fact, we added four (optional) new congestion control functions:
> 
> +       /* get the expiration time for the send timer (optional) */
> +       unsigned long (*get_send_timer_exp_time)(struct sock *sk);
> +       /* no data to transmit at the timer expiration (optional) */
> +       void (*no_data_to_transmit)(struct sock *sk);
> +       /* the send timer is expired (optional) */
> +       void (*send_timer_expired)(struct sock *sk);
> +       /* the TCP has sent some segments (optional) */
> +       void (*segment_sent)(struct sock *sk, u32 sent);
> 
> And a timer (tp->send_timer) which uses a send callback to push data down the
> stack. If the first of these function, get_send_timer_exp_time,  is not
> implemented by the current congestion control, then the timer sending timer is
> never set, therefore falling back to the old, ACK-clocked, behavior.

trimmed CC

This patch series seems to have missed recent efforts in TCP stack,
namely TCP pacing.

commit 218af599fa635b107cfe10acf3249c4dfe5e4123 ("tcp: internal
implementation for pacing") added a timer already to get fine grained
packet xmits.

I suggest you rebase your work and try to reuse existing mechanisms.

Thanks.
