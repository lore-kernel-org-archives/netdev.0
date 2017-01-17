From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: accept RST for rcv_nxt - 1 after
 receiving a FIN
Date: Tue, 17 Jan 2017 11:02:34 -0800
Message-ID: <1484679754.13165.70.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33270 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdAQTCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:02:36 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so6454088pfg.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:02:36 -0800 (PST)
In-Reply-To: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-17 at 13:37 -0500, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> Using a Mac OSX box as a client connecting to a Linux server, we have found
> that when certain applications (such as 'ab'), are abruptly terminated
> (via ^C), a FIN is sent followed by a RST packet on tcp connections. The
> FIN is accepted by the Linux stack but the RST is sent with the same
> sequence number as the FIN, and Linux responds with a challenge ACK per
> RFC 5961. The OSX client then sometimes (they are rate-limited) does not
> reply with any RST as would be expected on a closed socket.
> 
> This results in sockets accumulating on the Linux server left mostly in
> the CLOSE_WAIT state, although LAST_ACK and CLOSING are also possible.
> This sequence of events can tie up a lot of resources on the Linux server
> since there may be a lot of data in write buffers at the time of the RST.
> Accepting a RST equal to rcv_nxt - 1, after we have already successfully
> processed a FIN, has made a significant difference for us in practice, by
> freeing up unneeded resources in a more expedient fashion.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Jason !
