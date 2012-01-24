From: leno soff <lnxuff@gmail.com>
Subject: How to accelerate tcp retransmition
Date: Tue, 24 Jan 2012 16:58:31 +0800
Message-ID: <CAC=NXX3jdCAjmwTjQ-d43DWb-617a33nMcWb_UvBUyB_q7VZTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everyone,
   I have a lot of client, say C1, C2, .. Cn, which route packets to
my servers through router R. But R will drop 70% - 90% _ non-SYN _
packets from clients to Server.

  The clients and server work like http client and server, sending a
request, wating for the response.

  When router R drop the request-like packets(without SYN flag, of
cause), the clients retransmit with icsk_backoff++;  They usually
should wait 15 seconds+ (1+2+4+8), and sometimes more or just timeout.

   So, my question is:

        Is there any way in _server_ side, to accelerate the
retransmition like accelerating slow-start. I tried SO_KEEPALIVE in
server, interval == 1 second or less,  I assume the keepalive ack will
 accelerate the retransmition, ,  but it does not work:

       Flags [P.], seq 1:314, ack 1.  ----------------client request,
which is lost
       Flags [.], ack 1, win 905, length 0  --- server keepalive ack
       Flags [.], ack 1, win 115, length 0  --- client responds ack
       .... A lot keepalive and response.

    The client timeout because of RTO, why doesn't retransmit the
request packet but just an ack without data when it sees keepalive ack
?


Thanks.
