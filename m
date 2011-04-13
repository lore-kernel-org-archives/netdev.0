From: Daniel Walter <dwalter@barracuda.com>
Subject: [PATCH 1/1] ipv6: ignore looped-back NA while dad is running
Date: Wed, 13 Apr 2011 17:02:43 +0200
Message-ID: <1302706963.8923.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=EF=BB=BF[ipv6] Ignore looped-back NAs while in Duplicate Address Detec=
tion

If we send an unsolicited NA shortly after bringing up an
IPv6 address, the duplicate address detection algorithm
fails and the ip stays in tentative mode forever.=20
This is due a missing check if the NA is looped-back to us.

Signed-off-by: Daniel Walter <dwalter@barracuda.com>
---
apply against linux-2.6 HEAD

 net/ipv6/ndisc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)
---
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 92f952d..f057ff3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -945,9 +945,10 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	}
 	ifp =3D ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
-		if (ifp->flags & IFA_F_TENTATIVE) {
-			addrconf_dad_failure(ifp);
-			return;
+		if (skb->pkt_type !=3D PACKET_LOOPBACK
+		    && (ifp->flags & IFA_F_TENTATIVE)) {
+				addrconf_dad_failure(ifp);
+				return;
 		}
 		/* What should we make now? The advertisement
 		   is invalid, but ndisc specs say nothing







Barracuda Networks AG
Vorsitzender des Aufsichtsrates/ Chairman of the supervisory board: Dea=
n Drako
Vorstand/ Executive Board: Dr. Wieland Alge, Mag. Guenter Klausner
Sitz der Gesellschaft/ Registered office: 6020 Innsbruck, Austria
Handelsgericht Innsbruck Firmenbuch/ Registration Number: 184392s
UID-Nr/ VAT Number: ATU47509003

Diese Nachricht und allfaellige angehaengte Dokumente sind vertraulich =
und nur fuer den/die Adressaten bestimmt. Sollten Sie nicht der beabsic=
htigte Adressat sein, ist jede Offenlegung, Weiterleitung oder sonstige=
 Verwendung dieser Information nicht gestattet. In diesem Fall bitten w=
ir, den Absender zu verstaendigen und die Information zu vernichten. Fu=
er Uebermittlungsfehler oder sonstige Irrtuemer bei Uebermittlung beste=
ht keine Haftung.

This message and any attached files are confidential and intended solel=
y for the addressee(s). Any publication, transmission or other use of t=
he information by a person or entity other than the intended addressee =
is prohibited. If you receive this in error please contact the sender a=
nd delete the material. The sender does not accept liability for any er=
rors or omissions as a result of the transmission.


Barracuda Networks solutions are now available as virtual appliances. =0D
Visit www.barracudanetworks.com/vx for more information.=0D
=0D
=0D
