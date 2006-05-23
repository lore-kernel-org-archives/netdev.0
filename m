From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: [PATCH, 2.6.17-rc4-git10] ieee80211softmac_io.c: fix warning "defined but not used"
Date: Tue, 23 May 2006 15:49:40 +0200
Message-ID: <200605231549.43430.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1498409.d9gVgqcgLm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:20174 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1750753AbWEWNtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 09:49:46 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1498409.d9gVgqcgLm
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Got this compiler warning today and Johannes Berg <johannes@sipsolutions.net> wrote:

Yeah, known 'bug', we have that code there but never use it. Feel free
to submit a patch (to John Linville, CC netdev and softmac-dev) to
remove it.

Signed-off-by: Toralf Foerster <toralf.foerster@gmx.de>


--- linux-2.6.17-rc4-git10-pcie-rme9652/net/ieee80211/softmac/ieee80211softmac_io.c.old 2006-05-12 09:44:47.000000000 +0200
+++ linux-2.6.17-rc4-git10-pcie-rme9652/net/ieee80211/softmac/ieee80211softmac_io.c     2006-05-23 15:16:38.000000000 +0200
@@ -456,31 +456,3 @@
        return IEEE80211_2ADDR_LEN;
 }

-
-/* Sends a control packet */
-static int
-ieee80211softmac_send_ctl_frame(struct ieee80211softmac_device *mac,
-       struct ieee80211softmac_network *net, u32 type, u32 arg)
-{
-       void *pkt = NULL;
-       u32 pkt_size = 0;
-
-       switch(type) {
-       case IEEE80211_STYPE_RTS:
-       case IEEE80211_STYPE_CTS:
-               pkt_size = ieee80211softmac_rts_cts((struct ieee80211_hdr_2addr **)(&pkt), mac, net, type);
-               break;
-       default:
-               printkl(KERN_DEBUG PFX "Unsupported Control Frame type: %i\n", type);
-               return -EINVAL;
-       }
-
-       if(pkt_size == 0)
-               return -ENOMEM;
-
-       /* Send the packet to the ieee80211 layer for tx */
-       ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *) pkt, pkt_size);
-
-       kfree(pkt);
-       return 0;
-}


--nextPart1498409.d9gVgqcgLm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEcxL3hyrlCH22naMRAkCDAJ9kcIFpsByqquWVISAT8xmOAy/O0ACgqwrk
4g30DPhG0Xs6mmsYpw0xQRs=
=a1rc
-----END PGP SIGNATURE-----

--nextPart1498409.d9gVgqcgLm--
