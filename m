From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Wed, 1 Sep 2004 01:06:43 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409010106.54020.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200408312214.44701.vkondra@mail.ru> <20040831213719.GH31207@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1807251.l8n9aNYoZk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik <jgarzik@pobox.com>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, acx100-devel@lists.sourceforge.net,
        prism54-devel@prism54.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040831213719.GH31207@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1807251.l8n9aNYoZk
Content-Type: multipart/mixed;
  boundary="Boundary-01=_2ZPNBSf1w2nOWEF"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_2ZPNBSf1w2nOWEF
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<skip>
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p=
80211.tar.bz2=20
<skip>
LR> > - QoS stuff is not defined. I suppose recent cards will all support W=
ME
 and/or LR> > TGe. It is easy to add "QoS control" field to header and new
 frame types, but LR> > it is harder to formally define how PHY should hand=
le
 it. And, TGe is big LR> > story on itself, with all its HCCA, block ack,
 etc. I also think that QoS, as LR> > it is defined in TGe, required driver
 to have several tx queues and LR> > start/stop them separately. Is anyone
 working on it? I'll be glad to join. LR> >

I'd like to contribute easiest part of TGe, to start with something (agains=
t=20
source mentioned above). I defined only frame formats and bits for fixed=20
fields.

--Boundary-01=_2ZPNBSf1w2nOWEF
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="tge.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="tge.patch"

Index: if_80211.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /home/vkondra-l/cvsroot/p80211/if_80211.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 if_80211.h
=2D-- if_80211.h	31 Aug 2004 20:32:16 -0000	1.1.1.1
+++ if_80211.h	31 Aug 2004 21:29:58 -0000
@@ -31,6 +31,27 @@
 	u8 addr4[ETH_ALEN];
 };
=20
+struct ieee802_11_hdrq {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+	u16 qos_ctl;
+};
+
+struct ieee802_11_hdr4q {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+	u8 addr4[ETH_ALEN];
+	u16 qos_ctl;
+};
+
 /* Address field usage based upon setting of FROMDS/TODS bits:
  *
  * FROMDS	TODS	addr1	addr2	addr3	addr4
@@ -78,8 +99,11 @@
 #define IEEE802_11_STYPE_DISASSOC	0x00A0
 #define IEEE802_11_STYPE_AUTH		0x00B0
 #define IEEE802_11_STYPE_DEAUTH		0x00C0
+#define IEEE802_11_STYPE_ACTION		0x00D0
=20
 /* control */
+#define IEEE802_11_STYPE_BACK_REQ	0x0080
+#define IEEE802_11_STYPE_BACK		0x0090
 #define IEEE802_11_STYPE_PSPOLL		0x00A0
 #define IEEE802_11_STYPE_RTS		0x00B0
 #define IEEE802_11_STYPE_CTS		0x00C0
@@ -96,11 +120,51 @@
 #define IEEE802_11_STYPE_CFACK		0x0050
 #define IEEE802_11_STYPE_CFPOLL		0x0060
 #define IEEE802_11_STYPE_CFACKPOLL	0x0070
+#define IEEE802_11_STYPE_QDATA		0x0080
+#define IEEE802_11_STYPE_QDATA_CFACK	0x0090
+#define IEEE802_11_STYPE_QDATA_CFPOLL	0x00A0
+#define IEEE802_11_STYPE_QDATA_CFACKPOLL	0x00B0
+#define IEEE802_11_STYPE_QNULLFUNC	0x00C0
+#define IEEE802_11_STYPE_QCFACK		0x00D0
+#define IEEE802_11_STYPE_QCFPOLL		0x00E0
+#define IEEE802_11_STYPE_QCFACKPOLL	0x00F0
=20
 #define IEEE802_11_SCTL_FRAG		0x000F
 #define IEEE802_11_SCTL_SEQ		0xFFF0
 #define IEEE802_11_SCTL_SEQ_SHIFT	4
=20
+/** QOS control field bits usage
+ *  Frame               0..3  4     5..6        7     8..15
+ *=20
+ * QoS (+)CF-Poll       TID   EOSP  Ack_policy  rsrv  TXOP limit
+ * sent by HC
+ *=20
+ * QoS Data, QoS Null,  TID   EOSP  Ack_policy  rsrv  QAP PS buffer size
+ * QoS CF-Ack,
+ * QoS Data + CF-Ack
+ * sent by HC
+ *=20
+ * QoS Data sent by     TID   0     Ack_policy  rsrv  TXOP duration reques=
ted
+ * non-AP QSTA          TID   1     Ack_policy  rsrv  Queue size
+ *=20
+ */
+#define IEEE802_11_QCTL_FRAG		0x000F
+#define IEEE802_11_QCTL_EOSP		0x0010
+#define IEEE802_11_QCTL_ACK 		0x0060
+#define IEEE802_11_QCTL_VAL 		0xFF00
+
+/* bits for ack policy */
+#define IEEE802_11_QCTL_ACK_NORM 		0x0000  /* normal Ack      */
+#define IEEE802_11_QCTL_ACK_NO   		0x0020  /* No ack          */
+#define IEEE802_11_QCTL_ACK_NEXP 		0x0040  /* No explicit Ack */
+#define IEEE802_11_QCTL_ACK_BLK  		0x0060  /* Block Ack       */
+
+/* bits for QAP PS buffer size */
+#define IEEE802_11_QCTL_PSBUF_PRESENT 		0x0200  /* next fields present    =
*/
+#define IEEE802_11_QCTL_PSBUF_HI_AC   		0x0C00  /* highest AC buffered    =
*/
+#define IEEE802_11_QCTL_PSBUF_BUF     		0xF000  /* total buffered payload =
*/
+
+
 struct ieee802_11_snap {
 	u8	dsap;
 	u8	ssap;
@@ -119,6 +183,14 @@
 #define IEEE802_11_TLV_TYPE_TIM		5
 #define IEEE802_11_TLV_TYPE_IBSSPARMS	6
 #define IEEE802_11_TLV_TYPE_COUNTRY	7
+#define IEEE802_11_TLV_TYPE_QBSS_LOAD	11
+#define IEEE802_11_TLV_TYPE_EDCA	12
+#define IEEE802_11_TLV_TYPE_TSPEC	13
+#define IEEE802_11_TLV_TYPE_TCLAS	14
+#define IEEE802_11_TLV_TYPE_SCHED	15
+#define IEEE802_11_TLV_TYPE_TS_DELAY	43
+#define IEEE802_11_TLV_TYPE_TC_PROC	44
+#define IEEE802_11_TLV_TYPE_QOS_CAP	46
 #define IEEE802_11_TLV_TYPE_XRATES	50
=20
 #define IEEE802_11_MAX_RATES	8

--Boundary-01=_2ZPNBSf1w2nOWEF--

--nextPart1807251.l8n9aNYoZk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBNPZ9qxdj7mhC6o0RAnSOAKCHcA9FzXz7Zj1EJPYMz1IjlVjRCgCfQM6i
igW/a/012e2dk4wZ3Fq6lS8=
=CfSh
-----END PGP SIGNATURE-----

--nextPart1807251.l8n9aNYoZk--
