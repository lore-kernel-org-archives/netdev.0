From: Nathaniel M Nelson <nmn@chartermi.net>
Subject: Possible weird TCP bug
Date: Thu, 08 Jan 2004 23:16:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FFE2B00.2030607@chartermi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have encountered a strange issue with one of my linux machines (which 
happens to be my firewall/masquerading box)....it seems that the TCP 
sequence numbers that it generates for output start with "0".  This goes 
for any packet that originates from the firewall itself or any packets 
that are forwarded to that machine.  This does not seem right to 
me...any other linux box that I hook up to the WAN looks like they 
generate a normal sequence number. 

This particular system is running a Tyan Thunder/LE-T  2518GN 
motherboard which is a Dual Socket 370 board.  It has two Intel 82559 
LAN controllers.  Let me know if anyone needs more specs.  It was 
running the 2.4.22 kernel and now runs the 2.4.24 kernel and both have 
the same tcp sequence problem.  Below is a sample SYN packet going out 
to google.com.  It has a sequence # of "0".

0000  00 02 7d 66 a4 54 00 e0  81 23 14 78 08 00 45 00   ..}f.T.. .#.x..E.
0010  00 3c 9a 41 40 00 3f 06  f4 1f 18 e7 92 21 d8 ef   .<.A@.?. .....!..
0020  29 63 89 37 00 50 e5 4b  22 e0 00 00 00 00 a0 02   )c.7.P.K ".......
0030  16 d0 36 6a 00 00 02 04  05 b4 04 02 08 0a 03 1d   ..6j.... ........
0040  b8 a1 00 00 00 00 01 03  03 00                     ........ ..     

Then after I get the SYN,ACK back, the firewall will send out the next 
ACK with the sequence number correctly incremented by 1.

0000  00 02 7d 66 a4 54 00 e0  81 23 14 78 08 00 45 00   ..}f.T.. .#.x..E.
0010  00 28 9a 42 40 00 3f 06  f4 32 18 e7 92 21 d8 ef   .(.B@.?. .2...!..
0020  29 63 89 37 00 50 e5 4b  22 e1 db f2 5c c5 50 10   )c.7.P.K "...\.P.
0030  16 d0 21 3d 00 00                                  ..!=.

So of course the sequence is "1" in that packet.  Both sequence numbers 
seem a little low though... and not very cryptic.  If this is not a bug 
I apoligize in advance.

(Please CC replies to nmn@chartermi.net as I am not subscribed.)
