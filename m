From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN cookies: validity range
Date: Tue, 06 Jun 2017 16:10:35 -0700
Message-ID: <1496790635.736.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACBbrCDcgxDirTvrM39o5ZX8gmr2O3WJhkxyCzwN0LMLhcdwKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Juan =?ISO-8859-1?Q?Jos=E9?= Echevarria
        <juanjose.echevarria@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36824 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751436AbdFFXKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 19:10:38 -0400
Received: by mail-pg0-f45.google.com with SMTP id a70so32240340pge.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 16:10:38 -0700 (PDT)
In-Reply-To: <CACBbrCDcgxDirTvrM39o5ZX8gmr2O3WJhkxyCzwN0LMLhcdwKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-07 at 00:12 +0200, Juan José Echevarria wrote:
> Hi,
> 
> This is my first post, hope I'm not using the mailing list wrongly.
> 
> As proposed in an old thread
> (https://www.spinics.net/lists/netdev/msg329144.html), when we send
> SYN cookies and then exit this mode, tcp_synq_no_recent_overflow()
> returns false if cookies are received until 2 minutes later
> (TCP_SYNCOOKIE_VALID).
> 
> Despite the rest of the SYN cookie code allows ACKs be aged up to 2
> minutes, we should not accept cookies for that long if the SYN cookie
> episode is over. As we dont keep state, an ACK with a previous cookie
> will be assumed as a valid third packet of a TCP connection.
> 
> In this scenario, the validity range allows a client not to wait for a
> SYN-ACK most of the time. A client could intentionally send the
> required number of packets to fill the queue (eg, with a spoofed IP
> address). Then, it could open a connection, collect the cookie, and
> reuse it to speed up the opening of successive connections for 2
> minutes. This cheat -specially attractive in low-end devices, where
> the SYN queue is rather small- may behave similarly to TCP Fast Open,
> but without the awareness of the server.

No idea why someone would use this unreliable convoluted way, instead of
Fast Open ;)

> 
> Decreasing TCP_SYNCOOKIE_VALID would prevent the replay of cookies.

It will also prevent connections from innocent users with RTT of say 30
seconds (seen in real world conditions)
