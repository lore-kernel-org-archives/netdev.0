From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Three way TCP handshake : can we avoid the third packet ?
Date: Tue, 21 Sep 2004 11:47:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414FF8BF.4070302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

I discovered today that some TCP stackes are able to initiate TCP 
sockets with 2 packets "only".

The third packet (ACK packet) is just delayed and integrated into the 
data packet.

11:07:15.551507 host1.11906 > host2.80: S 1522618044:1522618044(0) win 
64240 <mss 1452,nop,nop,sackOK> (DF)

11:07:15.551523 host2.80 > host1.11906: S 751859039:751859039(0) ack 
1522618045 win 5840 <mss 1460> (DF)

11:07:16.112451 host1.11906 > host2.80: P 1:92(91) ack 1 win 65340

11:07:16.151800 host2.80 > host1.11906: . ack 92 win 5840 (DF)

It seems to be valid (host2 is linux in this tcpdump output), and saves 
one packet.

Is it possible to achieve the same thing with linux 2.4/2.6 ?

A magical setsockopt() thing like TCP_CORK, TCP_QUICKACK, after the 
socket() call and before the connect() ?

Thank you
Eric Dumazet
