From: Krzysztof Oledzki <olel@ans.pl>
Subject: Problem with Linux-2.6.x+ipsec-tools & Linksys BEFSX41
Date: Thu, 10 Mar 2005 23:42:45 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503102316570.25419@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="-187430788-1267226255-1108125500=:11121"
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.62.0503102316571.25419@bizon.gios.gov.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1267226255-1108125500=:11121
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-2; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.62.0503102316572.25419@bizon.gios.gov.pl>

Hello,

I have problem with IPSec between 2.6.x Linux native IPsec and Linksys BEFS=
X41=20
router. Everything works fine until key renegotiation. Routers are able to=
=20
exchange keys & setup IPSec connection:

Feb 11 12:29:16 gw1 racoon: INFO: @(#)ipsec-tools 0.4 (http://ipsec-tools.s=
ourceforge.net)
Feb 11 12:29:16 gw1 racoon: INFO: @(#)This product linked OpenSSL 0.9.7e 25=
 Oct 2004 (http://www.openssl.org/)
Feb 11 12:29:16 gw1 racoon: INFO: BBB.BB.BB.BB[500] used as isakmp port (fd=
=3D7)
Feb 11 12:29:16 gw1 racoon: INFO: IPsec-SA request for AA.AA.AAA.AAA queued=
 due to no phase1 found.
Feb 11 12:29:16 gw1 racoon: INFO: initiate new phase 1 negotiation: BBB.BB.=
BB.BB[500]<=3D>AA.AA.AAA.AAA[500]
Feb 11 12:29:16 gw1 racoon: INFO: begin Identity Protection mode.
Feb 11 12:29:19 gw1 racoon: INFO: ISAKMP-SA established BBB.BB.BB.BB[500]-A=
A.AA.AAA.AAA[500] spi:5e657591032b23ce:3f6df2be5d610c99
Feb 11 12:29:20 gw1 racoon: INFO: initiate new phase 2 negotiation: BBB.BB.=
BB.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 12:29:22 gw1 racoon: WARNING: attribute has been modified.
Feb 11 12:29:22 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BBB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 12:29:22 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BBB.BB.B=
B.BB->AA.AA.AAA.AAA spi=3D1042970307(0x3e2a76c3)

After 48 minutes (hard limit is 3600s and soft 2880s) racoon starts negotia=
ting=20
new keys and then tunnel stops working.

Feb 11 13:17:22 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:22 gw1 racoon: INFO: IPsec-SA request for AA.AA.AAA.AAA queued=
 due to no phase1 found.
Feb 11 13:17:22 gw1 racoon: INFO: initiate new phase 1 negotiation: BB.BB.B=
B.BB[500]<=3D>AA.AA.AAA.AAA[500]
Feb 11 13:17:22 gw1 racoon: INFO: begin Identity Protection mode.
Feb 11 13:17:22 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel BB.BB.BB.BB-=
>AA.AA.AAA.AAA spi=3D1042970307(0x3e2a76c3)
Feb 11 13:17:31 gw1 racoon: INFO: ISAKMP-SA established BB.BB.BB.BB[500]-AA=
=2EAA.AAA.AAA[500] spi:14cb86caec437624:0c11453a860aa178
Feb 11 13:17:32 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:35 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:35 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:35 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D456046736(0x1b2eb890)
Feb 11 13:17:36 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:36 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:48 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:48 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:48 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D984883126(0x3ab41fb6)
Feb 11 13:17:49 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:49 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:50 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:50 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:50 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D2443714535(0x91a81fe7)
Feb 11 13:17:51 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:51 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:52 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:52 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:52 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D891474119(0x3522d0c7)
Feb 11 13:17:53 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:53 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:56 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:56 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:56 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D3294034757(0xc456fb45)
Feb 11 13:17:57 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:57 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:17:59 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:17:59 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:17:59 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D1251852702(0x4a9dc19e)
Feb 11 13:18:00 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:00 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:18:02 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:18:02 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:02 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D522496593(0x1f24aa51)
Feb 11 13:18:03 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:03 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:18:06 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:18:06 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:06 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D1163930963(0x45602d53)
Feb 11 13:18:07 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:07 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
Feb 11 13:18:08 gw1 racoon: WARNING: attribute has been modified.
Feb 11 13:18:08 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel AA.AA.AA=
A.AAA->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:08 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel BB.BB.BB=
=2EBB->AA.AA.AAA.AAA spi=3D3167100563(0xbcc61e93)
Feb 11 13:18:09 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:18:09 gw1 racoon: INFO: initiate new phase 2 negotiation: BB.BB.B=
B.BB[0]<=3D>AA.AA.AAA.AAA[0]
(...)
  <more messages like those>
(...)
Feb 11 13:23:46 gw1 racoon: ERROR: AA.AA.AAA.AAA give up to get IPsec-SA du=
e to time up to wait.

and finally...

Feb 11 13:29:22 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel AA.AA.AAA.AA=
A->BB.BB.BB.BB spi=3D151969078(0x90edd36)
Feb 11 13:29:22 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel BB.BB.BB.BB-=
>AA.AA.AAA.AAA spi=3D1042970307(0x3e2a76c3)

And then I need to restart reacoon.


I have already asked this question Ipsec-tools-devel ML but after some=20
additional test it seems that this it may be a bug in IPsec implementatnio=
=20
on Linux - this tunnel works just fine on FreeBSD 4.10 & both racoons from=
=20
KAME & ipsec-tools package. I tested Linux 2.4.10, 2.4.11-rc (1,2,3 & 4)=20
and finally 2.4.11 kernel, but this problem still exists.

As far as I understand linux IPSec code, when a SA's soft limit is reached=
=20
kernel sends notification to userspace daemon (racoon for example) and=20
asks it to get a new SA. I have changed expiration time to much smaller=20
values (hard: 120s, soft: 96s) and found that "renegotiation loop" only=20
exists in 96s-120s window. After 120s both SAs=20
(AA.AA.AAA.AAA->BBB.BB.BB.BB & BBB.BB.BB.BB->AA.AA.AAA.AAA) are removed=20
and then renegotiation loop stops. It is not clear to my why kernel tels=20
racoon about SA expiration more than once and why racoon can't simply=20
ignores additional messages?

Anyway, such behavior can also be sometimes observerd between my two Linux=
=20
routers but it happend very, very rarely.

Best regards,


 =09=09=09Krzysztof Ol=EAdzki
---187430788-1267226255-1108125500=:11121--
