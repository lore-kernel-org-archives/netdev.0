From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: TCP stalls - sack?, 2.6.12pre6
Date: Sat, 11 Jun 2005 19:44:28 +0200
Message-ID: <m3aclw23gj.fsf@defiant.localdomain>
References: <m3mzpz87dc.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <m3mzpz87dc.fsf@defiant.localdomain> (Krzysztof Halasa's
 message of "Fri, 10 Jun 2005 00:58:55 +0200")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Another TCP stall (2.6.12pre6 on both ends):

> intrepid is X11-server with ssh connection to defiant (X11-forwarding,
> EPIC100 PCI NIC). defiant is an older notebook machine and it was running
> XEmacs and Firefox with ssh/X11 (cardbus DEC 21143).
> Both on the same Ethernet subnet. Both standard MTU etc.

[DEF] is TCP defiant:ssh
[INT] is TCP intrepid:4782

intrepid:~# netstat -to | grep 4782; tcpdump -w stall -s 1600 -i eth0
Sat Jun 11 15:55:51 CEST 2005
Recv-Q Send-Q
tcp  0      0 [INT] [DEF] ESTABLISHED keepalive (675.46/0/0)

tcpdump file basically shows (TCP already stalled):

15:56:27.1 [INT] > [DEF]: P 569644050:569644162(112) ack 3725119932 win 31164 <nop,nop,timestamp 6388700 274348581,nop,nop,sack sack 1 {1449:14985} >
15:56:27.1 [DEF] > [INT]: . ack 112 win 16022 <nop,nop,timestamp 274631570 6388700>
15:56:27.1 [INT] > [DEF]: P 112:256(144) ack 1 win 31164 <nop,nop,timestamp 6388701 274348581,nop,nop,sack sack 1 {1449:14985} >
15:56:27.1 [DEF] > [INT]: . ack 256 win 16022 <nop,nop,timestamp 274631571 6388701>
15:56:27.1 [INT] > [DEF]: P 256:336(80) ack 1 win 31164 <nop,nop,timestamp 6388710 274348581,nop,nop,sack sack 1 {1449:14985} >
15:56:27.1 [DEF] > [INT]: . ack 336 win 16022 <nop,nop,timestamp 274631579 6388710>

...


16:04:09.6 [DEF] > [INT]: . ack 35536 win 16022 <nop,nop,timestamp 275094166 6851304>
16:04:09.7 [INT] > [DEF]: P 35536:35616(80) ack 1 win 31164 <nop,nop,timestamp 6851394 274348581,nop,nop,sack sack 1 {1449:14985} >
16:04:09.7 [DEF] > [INT]: . ack 35616 win 16022 <nop,nop,timestamp 275094256 6851394>
16:05:12.7 [DEF] > [INT]: . 1:1449(1448) ack 35616 win 16022 <nop,nop,timestamp 275157275 6851394>
16:08:14.3 [INT] > [DEF]: P 35616:35760(144) ack 1 win 31164 <nop,nop,timestamp 7096034 274348581,nop,nop,sack sack 1 {1449:14985} >
16:08:14.3 [DEF] > [INT]: R 3725119932:3725119932(0) win 0


defiant:~# netstat -to | grep 4782
Recv-Q Send-Q
tcp  0  54512 [DEF] [INT] ESTABLISHED on (81.30/10/0)

and Send-Q is constant until TCP reset.

> Ideas?

-- 
Krzysztof Halasa
