From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] tcp: accept RST for rcv_nxt - 1 after receiving
 a FIN
Date: Tue, 17 Jan 2017 11:04:48 -0800
Message-ID: <92daa9c2-7bfc-94ff-bb06-91ef03cd0d66@hpe.com>
References: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Jason Baron <jbaron@akamai.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:60900 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdAQTEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:04:55 -0500
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com [15.241.140.75])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 35D291624
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 19:04:50 +0000 (UTC)
In-Reply-To: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 10:37 AM, Jason Baron wrote:
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

Drifting a bit, and it doesn't change the value of dealing with it, but 
out of curiosity, when you say mostly in CLOSE_WAIT, why aren't the 
server-side applications reacting to the read return of zero triggered 
by the arrival of the FIN?

happy benchmarking,

rick jones
