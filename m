From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Ipsec-tools-devel] more phase 2 reinitiation problems
Date: Fri, 18 Mar 2005 15:43:47 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503181523510.4403@bizon.gios.gov.pl>
References: <42334B29.2080504@gmx.at>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1420858565-1111157027=:4403"
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com
To: Wilfried Weissmann <Wilfried.Weissmann@gmx.at>
In-Reply-To: <42334B29.2080504@gmx.at>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1420858565-1111157027=:4403
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 12 Mar 2005, Wilfried Weissmann wrote:

> Hi,
Hi,

> The rekeying also fails with debian's racoon 0.5 <=3D<internet>=3D> WinXP=
 (see=20
> Problem with Linux-2.6.x+ipsec-tools-0.4/0.5-rc1/0.5rc2 & Linksys BEFSX41=
). I=20
> am running the linux 2.6.11.2 kernel with IPSec connection tracking patch=
es.=20
> The configuration file and the log is attached.
> I also have problems between 2 linux boxes in the LAN but the other box i=
s=20
> still running racoon 0.3.3 which might be the cause of the LAN trouble.

Please giva a try try the 2.6.12-rc1 kernel. I have just upgraded my=20
system to this kernel and it seems that IPSec is able to survive first=20
rekeying. Unfortunately only a first one - after a while (just before=20
removing old expired keys) one of newly generated keys get removed and new=
=20
traffic racoon generates two news keys. OK, it is _much_ better but=20
still... not perfect.

My log with some comments:

Mar 18 11:47:36 gw1 racoon: INFO: @(#)ipsec-tools 0.5 (http://ipsec-tools.s=
ourceforge.net)
Mar 18 11:47:36 gw1 racoon: INFO: @(#)This product linked OpenSSL 0.9.7e 25=
 Oct 2004 (http://www.openssl.org/)
Mar 18 11:47:36 gw1 racoon: INFO: XXX.XX.XX.XX[500] used as isakmp port (fd=
=3D7)
Mar 18 11:47:36 gw1 racoon: INFO: XXX.XX.XX.XX[500] used for NAT-T
Mar 18 11:48:09 gw1 racoon: INFO: IPsec-SA request for YY.YY.YYY.YYY queued=
 due to no phase1 found.
Mar 18 11:48:09 gw1 racoon: INFO: initiate new phase 1 negotiation: XXX.XX.=
XX.XX[500]<=3D>YY.YY.YYY.YYY[500]
Mar 18 11:48:09 gw1 racoon: INFO: begin Identity Protection mode.
Mar 18 11:48:19 gw1 racoon: INFO: ISAKMP-SA established XXX.XX.XX.XX[500]-Y=
Y.YY.YYY.YYY[500] spi:a2acc8844df9591b:29621f95bfa3 8d45
Mar 18 11:48:20 gw1 racoon: INFO: initiate new phase 2 negotiation: XXX.XX.=
XX.XX[0]<=3D>YY.YY.YYY.YYY[0]
Mar 18 11:48:23 gw1 racoon: WARNING: attribute has been modified.
Mar 18 11:48:23 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel YY.YY.YY=
Y.YYY->XXX.XX.XX.XX spi=3D172047746(0xa413d82)
Mar 18 11:48:23 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel XXX.XX.X=
X.XX->YY.YY.YYY.YYY spi=3D993793125(0x3b3c1465)
OK. Kernel noticed some traffic and racooon generates new keys.

Mar 18 12:36:23 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel YY.YY.YYY.YY=
Y->XXX.XX.XX.XX spi=3D172047746(0xa413d82)
Mar 18 12:36:23 gw1 racoon: INFO: initiate new phase 2 negotiation: XXX.XX.=
XX.XX[0]<=3D>YY.YY.YYY.YYY[0]
Mar 18 12:36:23 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel XXX.XX.XX.XX=
->YY.YY.YYY.YYY spi=3D993793125(0x3b3c1465)
Mar 18 12:36:27 gw1 racoon: WARNING: attribute has been modified.
Mar 18 12:36:27 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel YY.YY.YY=
Y.YYY->XXX.XX.XX.XX spi=3D31676947(0x1e35a13)
Mar 18 12:36:27 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel XXX.XX.X=
X.XX->YY.YY.YYY.YYY spi=3D677995285(0x28696315)
OK! :) Old keys have just expired and racoon generates new ones. No=20
infinite loop! ;-) Yes!

Mar 18 12:48:18 gw1 racoon: INFO: purged IPsec-SA proto_id=3DESP spi=3D6779=
95285.
But what is this? We have just generated new key with spi=3D677995285. Why=
=20
it is now purged?

Mar 18 12:48:19 gw1 racoon: INFO: purged ISAKMP-SA proto_id=3DISAKMP spi=3D=
a2acc8844df9591b:29621f95bfa38d45.
Mar 18 12:48:20 gw1 racoon: INFO: ISAKMP-SA deleted XXX.XX.XX.XX[500]-YY.YY=
=2EYYY.YYY[500] spi:a2acc8844df9591b:29621f95bfa38d45

Mar 18 12:48:20 gw1 racoon: ERROR: unknown Informational exchange received.
Mar 18 12:48:23 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel YY.YY.YYY.YY=
Y->XXX.XX.XX.XX spi=3D172047746(0xa413d82)
Mar 18 12:48:23 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel XXX.XX.XX.XX=
->YY.YY.YYY.YYY spi=3D993793125(0x3b3c1465)
OK. Oldest keys now really expired, they are removed.

Mar 18 12:51:31 gw1 racoon: INFO: IPsec-SA request for YY.YY.YYY.YYY queued=
 due to no phase1 found.
Mar 18 12:51:31 gw1 racoon: INFO: initiate new phase 1 negotiation: XXX.XX.=
XX.XX[500]<=3D>YY.YY.YYY.YYY[500]
Mar 18 12:51:31 gw1 racoon: INFO: begin Identity Protection mode.
Mar 18 12:51:40 gw1 racoon: INFO: ISAKMP-SA established XXX.XX.XX.XX[500]-Y=
Y.YY.YYY.YYY[500] spi:8f29dd5a50fd83dd:ae84b9eee139 89e5
Mar 18 12:51:41 gw1 racoon: INFO: initiate new phase 2 negotiation: XXX.XX.=
XX.XX[0]<=3D>YY.YY.YYY.YYY[0]
Mar 18 12:51:43 gw1 racoon: WARNING: attribute has been modified.
Mar 18 12:51:43 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel YY.YY.YY=
Y.YYY->XXX.XX.XX.XX spi=3D140244397(0x85bf5ad)
Mar 18 12:51:43 gw1 racoon: INFO: IPsec-SA established: ESP/Tunnel XXX.XX.X=
X.XX->YY.YY.YYY.YYY spi=3D3173924318(0xbd2e3dde)
Kernel noticed some traffic (again), there is no known key for encription=
=20
(it was pugred @12:48:18), racooon generates new keys.

Mar 18 13:24:27 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel YY.YY.YYY.YY=
Y->XXX.XX.XX.XX spi=3D31676947(0x1e35a13)
Mar 18 13:36:27 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel YY.YY.YYY.YY=
Y->XXX.XX.XX.XX spi=3D31676947(0x1e35a13)
Mar 18 13:39:43 gw1 racoon: INFO: IPsec-SA expired: ESP/Tunnel YY.YY.YYY.YY=
Y->XXX.XX.XX.XX spi=3D140244397(0x85bf5ad)=20
Old keys get expired. BTW: Why key with spi=3D31676947 is expired twice?
(...)

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-1420858565-1111157027=:4403--
