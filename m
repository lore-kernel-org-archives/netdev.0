From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: Re: [RFC PATCH v1 0/5] TCP Wave
Date: Sat, 2 Sep 2017 22:33:20 +0200
Message-ID: <20170902203320.mqkv5u7ji7keuffa@judith.localdomain>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
 <1501306413.1876.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36182 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdIBUdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 16:33:24 -0400
Received: by mail-wm0-f54.google.com with SMTP id i145so2563862wmf.1
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 13:33:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1501306413.1876.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
first of all, we would like to thank everyone that commented our
patches; we are working to include all the suggestions (we are at a good
point).

However, we have two questions:

1) How to retrieve information about each connection? Right now we used
debug messages, but we understand it isn't the best option. TCP Wave
users have other values to track rather than congestion window and slow
start threshold. It seems we have two alternatives: (a) use get_info,
that returns strings to be read with ss, (b) open a file under /proc/net
and write data to it, in the same way as tcp_probe do. With option (a)
it is necessary a poll from userspace (for instance, using watch), but
is subjected to delays and maybe not suitable for fast connections
(watch minimum interval is 100 ms). Option (b), toggled with a module
parameter, seems the more viable. Is that correct?

The second one is inline:

On 28/07/17 at 10:33pm, Eric Dumazet wrote:
> On Fri, 2017-07-28 at 21:59 +0200, Natale Patriciello wrote:
> > Hi,
[cut]
> > TCP Wave (TCPW) replaces the window-based transmission paradigm of the standard
> > TCP with a burst-based transmission, the ACK-clock scheduling with a
> > self-managed timer and the RTT-based congestion control loop with an Ack-based
> > Capacity and Congestion Estimation (ACCE) module. In non-technical words, it
> > sends data down the stack when its internal timer expires, and the timing of
> > the received ACKs contribute to updating this timer regularly.
>
> This patch series seems to have missed recent efforts in TCP stack,
> namely TCP pacing.
>
> commit 218af599fa635b107cfe10acf3249c4dfe5e4123 ("tcp: internal
> implementation for pacing") added a timer already to get fine grained
> packet xmits.

Thank you, Eric, for this suggestion; in fact, we had problems with our
implementation of the timer, and we would like to switch to the new
pacing timer entirely. However, a pacing approach is exactly the
opposite we would like to achieve: we want to send a burst of data
(let's say, ten segments) and then wait some amount of time. Do you
think that adding a new congestion control callback that returns the
number of segments to send when the timer expires (default to 1) and another
callback for retrieving the pacing time can be a sound strategy?

Thank you again, have a nice day.

Natale
