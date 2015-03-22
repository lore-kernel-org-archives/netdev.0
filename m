From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link
Date: Sun, 22 Mar 2015 16:14:46 +0100
Message-ID: <201503221614.47994.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <201503220912.39912.wrosner@tirnet.de> <1427020159.25985.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:43478 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbbCVPOx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 11:14:53 -0400
In-Reply-To: <1427020159.25985.43.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric,=20

Am Sonntag, 22. M=C3=A4rz 2015 11:29:19 schrieben Sie:
> On Sun, 2015-03-22 at 09:12 +0100, Wolfgang Rosner wrote:
> > Am Samstag, 21. M=C3=A4rz 2015 22:48:22 schrieben Sie:
> > > On Sat, 2015-03-21 at 12:32 +0100, Wolfgang Rosner wrote:
> > > > btw: as it looks to me, the current git version seems to ignore=
 the
> > > > dsc filter. Sorry, you have to dig for the right line.
> > >
> > > Note I mentioned dst not dsc ;)
> >
> > sorry for the typo, but it's only in the mail text.
> > In the script it says "dst"
> > and  I checked it again.

> >
> > Anyway, I think this tiny bug is not going to hurt us here, is it?
> >
> > Wolfgang
> >
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > root@cruncher:/home/tmp/netdev#
> > /home/build/iproute2/shemminger/iproute2/misc/ss -temoi dst
> > 192.168.130.225
> > State      Recv-Q Send-Q                                    Local
> > Address:Port Peer Address:Port
> > ESTAB      0      0                                        =20
> > 192.168.0.53:ssh 192.168.0.50:21760               =20

> > (....)
>
> ss -temoi dst 192.168.130.225
>
> should not output tcp sessions to other destination than 192.168.130.=
225
>
> Your example shows sessions to 192.168.0.50, this makes no sense to m=
e.


Agree.=20
This is why I considered it as a bug.

But just a sideline, not my main problem.
And maybe it is even related to my build environment.
Or to the fact that I call it with full path. or whatever....

I don't know whether this repo you pointed me
https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/ =20
is a bleeding edge developer fork, that is expected to show such fluctu=
ations,=20
or a should-be-stable mainstream one, where such behaviur is not suppos=
ed to=20
occur.=20

So if for you, there is reason to worry on this issue, we can try to de=
bug=20
into it. Let me know, and give me instructions for tests, if required.





However, from my perspective, I'd prefer to return to my real problem:
	"One way TCP bottleneck over 6 x Gbit tecl aggregated link"

If you got lost in the flood of netdev list (I just subscribed, and am =
really=20
overwhelmed...), I don't mind to send you the info again and even remov=
e the=20
superfluous lines manually for you - see below.

Do these figure tell you a story?
Any hint where to look for a bottleneck?
Presumaly related to some per-TCP-connection ressource?


Wolfgang Rosner


#######################################################################=
###


# cat test.sh

SSPATH=3D/home/build/iproute2/shemminger/iproute2/misc/ss
SEP=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

(sleep 5 ; echo $SEP; $SSPATH -temoi dst 192.168.130.225 ; echo $SEP ) =
&

nstat >/dev/null
iperf -c 192.168.130.225
echo $SEP
nstat



# end of test script
#######################################################################=
##
# output follows, superflous lines from ss bug removed manually


------------------------------------------------------------
Client connecting to 192.168.130.225, TCP port 5001
TCP window size:  488 KByte (default)
------------------------------------------------------------
[  3] local 192.168.130.250 port 39256 connected with 192.168.130.225 p=
ort=20
5001
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

# ....ss output - buggy lines removed ....

State      Recv-Q Send-Q Local Address:Port                 Peer Addres=
s:Port               =20
ESTAB      0      4554532 192.168.130.250:39256               =20
192.168.130.225:5001                  timer:(on,200ms,0) ino:514423=20
sk:ffff8801bdddd140 <->
	 skmem:(r0,rb500000,t66560,tb12000000,f3556096,w8469760,o0,bl3072) ts =
sack=20
cubic wscale:7,10 rto:204 rtt:0.357/0.01 mss:8948 cwnd:956 ssthresh:17 =
send=20
191692.7Mbps lastsnd:4 lastrcv:140569508 lastack:4 unacked:16 retrans:0=
/1=20
sacked:1 reordering:22 rcv_space:26880

# .... buggy lines removed ....


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  3.78 GBytes  3.24 Gbits/sec
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#kernel
IpInReceives                    444749             0.0
IpForwDatagrams                 4                  0.0
IpInDelivers                    444745             0.0
IpOutRequests                   453019             0.0
TcpActiveOpens                  1                  0.0
TcpInSegs                       444742             0.0
TcpOutSegs                      453013             0.0
TcpRetransSegs                  1                  0.0
UdpInDatagrams                  1                  0.0
UdpOutDatagrams                 1                  0.0
UdpIgnoredMulti                 2                  0.0
TcpExtTCPHPHits                 12                 0.0
TcpExtTCPPureAcks               125155             0.0
TcpExtTCPHPAcks                 71412              0.0
TcpExtTCPSackRecovery           1                  0.0
TcpExtTCPSACKReorder            9                  0.0
TcpExtTCPTSReorder              1                  0.0
TcpExtTCPPartialUndo            1                  0.0
TcpExtTCPFastRetrans            1                  0.0
TcpExtTCPDSACKRecv              1                  0.0
TcpExtTCPDSACKIgnoredNoUndo     1                  0.0
TcpExtTCPSackShiftFallback      50003              0.0
TcpExtTCPAutoCorking            23882              0.0
TcpExtTCPOrigDataSent           453010             0.0
TcpExtTCPHystartTrainDetect     1                  0.0
TcpExtTCPHystartTrainCwnd       17                 0.0
IpExtInBcastPkts                3                  0.0
IpExtOutBcastPkts               1                  0.0
IpExtInOctets                   24508230           0.0
IpExtOutOctets                  4076970728         0.0
IpExtInBcastOctets              538                0.0
IpExtOutBcastOctets             76                 0.0
IpExtInNoECTPkts                444749             0.0
