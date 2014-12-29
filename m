From: Zheng Yi <yzheng@techyauld.com>
Subject: [CPSW driver] broadcast ethernet pkg will be dropped?
Date: Mon, 29 Dec 2014 09:36:06 +0800
Message-ID: <20141229013606.GR970@techyauld.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Op27XXJsWz80g3oF"
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	Lokesh Vutla <lokeshvutla@ti.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular2.263xmail.com ([211.157.152.3]:35759 "EHLO
	regular2.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaL2Bgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 20:36:36 -0500
Received: from regular1.263xmail.com (unknown [192.168.165.232])
	by regular2.263xmail.com (Postfix) with ESMTP id 94EFE1D7CB
	for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 09:36:32 +0800 (CST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Op27XXJsWz80g3oF
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sir

   I found your mail address from Linux kernel git repo. I think there
   is a problem in CPSW driver. If it is not your duty to maintain
   those code, could you please tell me the ones who are in charge of
   it?

   I found that when a AM3352 board boot, I use a laptop to send ARP
   request to it, the board do not reponse. Even ifconfig do not show
   that there is any pkg sent to the CPSW device. I'm sure that the
   ARP request PKG received by SoC(confirmed by my oscilloscope).

   After reading the SoC doc (Tech ref manual) and reading the driver code,=
 i found that:
   15.3.2.7 Address Lookup Engine (ALE)
   "Broadcast packets will be dropped unless the broadcast address is enter=
ed into the table with the super bit set."

   and in driver: drivers/net/ether/ti/cpsw_ale.c

   int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
                          int flags, u16 vid, int mcast_state)
   {
          /* ....... */

          cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);

          /* ....... */
   }

   I have searched all of the calling of that function, and found no
   ALE_BLOCKED flag was set.  Especially, in
   cpsw_add_dual_emac_def_ale_entries(), only ALE_VLAN was provided
   for the broadcast address.

   After change the flag(brutally), my board can response to the ARP broadc=
ast requests correctly.

   Here are some questions I do not found the answer:
   1. the macro ALE_BLOCKED seems be used uncorrectly.
      If one want the pkg should be "blocked", the "super" bit should be cl=
eared, not be set.
      So, in cpsw_ale_add_mcast(), we should do like this:
          cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 0 : 1);

      Do you think the current logic is reversed?

   2. broadcast ethernet pkg from "FF:FF:FF:FF:FF:FF" should be alowed.
      If by default, it desiged to be filtered out, why not add an interfac=
e to support
      restore it? I do not found any code that can change filtering the bro=
adcast pkg in runtime.






--
Brock Zheng <yzheng@techyauld.com>
=E9=83=91 =E7=A5=8E

=E5=8C=97=E4=BA=AC=E4=B8=AD=E7=A7=91=E8=85=BE=E8=B6=8A=E7=A7=91=E6=8A=80=E5=
=8F=91=E5=B1=95=E6=9C=89=E9=99=90=E5=85=AC=E5=8F=B8
=E5=8C=97=E4=BA=AC=E5=B8=82=E6=B5=B7=E6=B7=80=E5=8C=BA=E4=B8=9C=E5=8C=97=E6=
=97=BA=E8=A5=BF=E8=B7=AF8=E5=8F=B7=E4=B8=AD=E5=85=B3=E6=9D=91=E8=BD=AF=E4=
=BB=B6=E5=9B=AD21=E5=8F=B7=E6=A5=BC=E5=90=AF=E6=98=8E=E6=98=9F=E8=BE=B0=E5=
=A4=A7=E5=8E=A6=E4=BA=8C=E5=B1=82=E5=85=AD=E5=8C=BA=EF=BC=88=E9=82=AE=E7=BC=
=96=EF=BC=9A100094=EF=BC=89

--Op27XXJsWz80g3oF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJUoLACAAoJEDc4PoRa6W2L2SkH/2AKOstnXWF7bwmQUnW7jRhq
kSAP31KbE7JkFodvzYbNIuwhx6UHYe6Yba9lHoRWRYrZuKJQkktRWo4mvbIxlcbG
9Fwtz4afbEqtchDGcqhzam2mV7hMCB3PLb5MjqyS+OfLY2bKIeyM4c003QQLw1md
JMHrNqGrcVPxfhyl/DL+A4SRgJTzFOCTOgNP6jUhAbWIhworyFcdp6CcWBRgv5g+
bw/nT1U/z7ZynoHu0lfEBCql2DY42lsWH27NaMQNo5k1T5cJi62dsHvWj8ECNVVr
cEnlN4WkawXxeIxXcJLRKRyRwZUJQ2zwbEEV/lwW+bkfkG9mmYYS639M0yGUY8A=
=YD+K
-----END PGP SIGNATURE-----

--Op27XXJsWz80g3oF--
