From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: TCP_DELACK_MIN vs TCP_ATO_MIN
Date: Wed, 21 Sep 2011 15:59:54 +0300
Message-ID: <CAEnQRZAObcdhikY6GzG3mC1KZjgK8Xp5LzNetczmZP=BRPqN6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f52.google.com ([209.85.212.52]:51711 "EHLO
	mail-vw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab1IUM7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:59:54 -0400
Received: by vws10 with SMTP id 10so2528003vws.11
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 05:59:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

RFC2582, Section 4.2 says:

"... an ACK SHOULD be generated for at least every second
full-sized segment, and MUST be generated within 500 ms
of the arrival of the first unacknowledged packet. ".


I guess that the delayed ACK timeout is computed in tcp_send_delayed_ack:

===
void tcp_send_delayed_ack(struct sock *sk)
{
        struct inet_connection_sock *icsk = inet_csk(sk);
        int ato = icsk->icsk_ack.ato;
        unsigned long timeout;

       /* .... */
        /* Stay within the limit we were given */
        timeout = jiffies + ato;
====


Can one explain what is the difference between TCP_DELACK_MIN and
TCP_ATO_MIN, specifically if the timeout (ato) is always in the interval
[TCP_DELACK_MIN, TCP_DELACK_MAX] ?

I want to make the delayed ack timeout configurable as some guys tried
here [1],
so for this reason I plan to make TCP_DELACK_MIN and TCP_DELACK_MAX
tunable via proc entries.

thanks,
Daniel.

[1] http://kerneltrap.org/mailarchive/linux-netdev/2008/9/9/3245554
