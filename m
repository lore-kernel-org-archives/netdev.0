From: Andersson =?iso-8859-1?Q?Bj=F6rn?= <Bjorn.Andersson@ebc.ericsson.se>
Subject: VLAN patches
Date: Mon, 30 Sep 2002 10:23:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D980A10.8B06F2C2@ebc.ericsson.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------71FD21E476E442E5A0CDA059"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------71FD21E476E442E5A0CDA059
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by albatross.wise.edt.ericsson.se id g8U8NjKV001031

Hi,
I hope you are the right receiver of 8021q-patches.
We are running SuSe 8.0, i.e kernel 2.4.18.

- When addding several egress-mappings we get stuck in an eternal
loop if they end up in the same hash-bucket, see vlan_dev.c.path.

- If we try to remove a vlan with VID 0, ifconfig stops working
completly.
We fixed it with vlan.c.patch.


--=20
* Bj=F6rn Andersson                   bjorn.andersson@ebc.ericsson.se *
* Ericsson Enterprise AB            NA/EBC/BEES/DNCC                *
* Nacka Strand                      tel: +46-8-422 3512             *
* 13 189 Stockholm, Sweden          fax: +46-8-422 1010             *
--------------71FD21E476E442E5A0CDA059
Content-Type: text/plain; charset=us-ascii;
 name="vlan.c.patch"
Content-Disposition: inline;
 filename="vlan.c.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.4.18.SuSE/net/8021q/vlan.c.orig	Wed Mar 27 13:57:17 2002
+++ linux-2.4.18.SuSE/net/8021q/vlan.c	Wed Sep 18 13:19:13 2002
@@ -207,7 +207,7 @@
 #endif
 
 	/* sanity check */
-	if ((vlan_id >= VLAN_VID_MASK) || (vlan_id <= 0))
+	if ((vlan_id >= VLAN_VID_MASK) || (vlan_id < 0))
 		return -EINVAL;
 
 	spin_lock_bh(&vlan_group_lock);

--------------71FD21E476E442E5A0CDA059
Content-Type: text/plain; charset=us-ascii;
 name="vlan_dev.c.patch"
Content-Disposition: inline;
 filename="vlan_dev.c.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.4.18.SuSE/net/8021q/vlan_dev.c.orig	Wed Mar 27 13:57:17 2002
+++ linux-2.4.18.SuSE/net/8021q/vlan_dev.c	Wed Sep 18 13:19:52 2002
@@ -570,6 +570,7 @@
 					dev_put(dev);
 					return 0;
 				}
+				mp = mp->next;
 			}
 
 			/* Create a new mapping then. */

--------------71FD21E476E442E5A0CDA059--
