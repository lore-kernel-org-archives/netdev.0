From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: TGe overview #2
Date: Sat, 17 Jul 2004 12:11:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407171211.15486.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

If we do only TXOP and 4 AC categories described in my previous posting, it 
will correspond to WME, which is another draft for QoS, implemented in some 
cards. Let's move on with TGe.

It defines 16 Traffic Identifiers (TID) per destination address (DA). This 
defines 16 independent streams simultaneously maintained. From these 16 
TID's, first 8 corresponds to 802.1d user priority and are statically mapped 
to 4 AC in this way:

TID    AC
1(BK)  1(AC_BK)
2      1(AC_BK)
0(BE)  0(AC_BE)
3(EE)  0(AC_BE)
4(CL)  2(AC_VI)
5(VI)  2(AC_VI)
6(VO)  3(AC_VO)
7(NC)  3(AC_VO)

Other 8 TID's, 8-15, used to describe Traffic Streams (TS), and used to 
implement IntServ like QoS.

To remind, access to the channel is per AC, with parameters dictated by AP. AP 
may change these parameters in run time.

Mechanics of EDCA parameters propagation and other details:
EDCA parameters (CWmin,CWmax,AIFSN,TXOP) included in beacon frame transmitted 
by AP periodically (every 100ms). TID included in each frame, there is 
special QoS field in 802.11 MAC header. How to distribute per AC time between 
TID's is not specified by standard. STA should specify its QoS capabilities 
when associating with AP. AP may reject STA that not support QoS. AP may 
analyze STA's behavour and disassociate it for protocol violation like over 
utilization of channel.

To summarize, this defined diffserv QoS with parameters dictated by AP.

In next post, I will describe HCCA (hybrid coordinated channel access) and 
IntServ like QoS.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA+O0zqxdj7mhC6o0RApt9AJ44/rSb7if9sjZYtE3WfnfTMnasLwCeOhuC
kCGwr/mJeoVU30MVB+dpLI8=
=GHGu
-----END PGP SIGNATURE-----
