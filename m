From: "Francois Baligant" <francois@baligant.net>
Subject: 2.6.0-test11: dst_cache_overflow causing unresponsive box
Date: Tue, 2 Dec 2003 02:32:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <072501c3b874$2542ae70$15fea8c0@fortress>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="----=_NextPart_000_0722_01C3B87C.80FBB1A0"
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format...

------=_NextPart_000_0722_01C3B87C.80FBB1A0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

We have a problem with a box running 2.6.0-test11-mjb1 and supporting aroun=
d 90k simultaneous TCP connection. After a few hours/days of running,
when a lots of clients connects/disconnects, the console will start to disp=
lay:

dst cache overflow
NET: 1860 messages suppressed.
dst cache overflow
NET: 1858 messages suppressed.


>From there, the box is completely unresponsive, apparently eating all its C=
PU in trying to shrink the routing cache. Only solution is reboot.

Current sysctl:
net.ipv4.route.max_size =3D 655360 # I know we shouldn't rise it that high =
but it's only cure for now.. it lasts a bit longer like this
net.ipv4.route.gc_min_interval =3D 2
net.ipv4.route.gc_interval =3D 10
net.ipv4.route.gc_timeout =3D 30

rtstat:
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
139566     12393     123     0     0     0     0     0       184      21   =
   0     143     142         0    0           26039        375
138876     13080     136     0     0     0     0     0       159      19   =
   0     155     154         0    0           27153        277
139006     12317     125     0     0     0     0     0       180      28   =
   0     153     153         0    0           25810        377
139138     13799     140     0     0     0     0     0       159      16   =
   0     156     156         0    0           28375        331
139275     11610     128     0     0     0     0     0       177      27   =
   0     154     153         0    0           23977        343
139383     12679     124     0     0     0     0     0       173      17   =
   0     141     140         0    0           26717        398
139256     11946     135     0     0     0     0     0       166      17   =
   0     152     151         0    0           24874        304
139353     11646     109     0     0     0     0     0       174      14   =
   0     122     122         0    0           24165        320
138257     12702     116     0     0     0     0     0       180      16   =
   0     131     130         0    0           26324        358
138369     12897     115     0     0     0     0     0       166      20   =
   0     134     134         0    0           26819        339
138553     11309     133     0     0     0     0     0       158      33   =
   0     165     165         0    0           21270        389
138172     17232     182     0     0     0     0     0       125      44   =
   0     225     225         0    0           29702        375
138420     17407     182     0     0     0     0     0       165      73   =
   0     254     253         0    0           29946        548
138833     17052     257     0     0     0     0     0       195     126   =
   0     382     381         0    0           29715        812
139051     16606     224     0     0     0     0     0       238      97   =
   0     320     319         0    0           28559        721
139217     18115     176     0     0     0     0     0       268      51   =
   0     224     224         0    0           32983        527
139326     17531     178     0     0     0     0     0       291      44   =
   0     220     220         0    0           33320        445
139422     15244     140     0     0     0     0     0       357      20   =
   0     160     160         0    0           29934        415
139548     13123     142     0     0     0     0     0       281      12   =
   0     154     154         0    0           26430        351
139684     13290     142     0     0     0     0     0       235      10   =
   0     152     151         0    0           27341        309

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20
142340 142296  99%    0.38K  14234       10     56936K ip_dst_cache

Are we tuning the rt_cache in a wrong way ?

regards,
Francois

Francois Baligant - http://www.pingouin.be
Change the numbers, change your Life!
------=_NextPart_000_0722_01C3B87C.80FBB1A0--
