From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: Fwd: Re: net/ieee80211/softmac/ieee80211softmac_io.c:464: warning: 'ieee80211softmac_send_ctl_frame' defined but not used
Date: Tue, 23 May 2006 14:45:39 +0200
Message-ID: <200605231445.43205.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3055047.fcpR84OWpo";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:38311 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751187AbWEWMpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 08:45:45 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3055047.fcpR84OWpo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline



=2D---------  Weitergeleitete Nachricht  ----------

Subject: Re: net/ieee80211/softmac/ieee80211softmac_io.c:464:=20
warning: 'ieee80211softmac_send_ctl_frame' defined but not used
Date: Tuesday 23 May 2006 14:33
=46rom: Johannes Berg <johannes@sipsolutions.net>
To: Toralf F=F6rster <toralf.foerster@gmx.de>
Cc: linuxppc-dev@ozlabs.org

On Mon, 2006-05-22 at 19:48 +0200, Toralf F=F6rster wrote:
> While playing with various kernel config I observed the warning above
> compiling 2.6.17-rc4-git10.

Yeah, known 'bug', we have that code there but never use it. Feel free
to submit a patch (to John Linville, CC netdev and softmac-dev) to
remove it.

johannes

=2D------------------------------------------------------

Here is a patch applicable fotr the current git kernel:

n22 ~ # cat patch_softmac
=2D-- net/ieee80211/softmac/ieee80211softmac_io.c 2006-05-23 14:41:19.00000=
0000=20
+0200
+++ net/ieee80211/softmac/ieee80211softmac_io.c_orig    2006-05-23=20
14:40:44.000000000 +0200
@@ -456,3 +456,31 @@
        return IEEE80211_2ADDR_LEN;
 }

+
+/* Sends a control packet */
+static int
+ieee80211softmac_send_ctl_frame(struct ieee80211softmac_device *mac,
+       struct ieee80211softmac_network *net, u32 type, u32 arg)
+{
+       void *pkt =3D NULL;
+       u32 pkt_size =3D 0;
+
+       switch(type) {
+       case IEEE80211_STYPE_RTS:
+       case IEEE80211_STYPE_CTS:
+               pkt_size =3D ieee80211softmac_rts_cts((struct=20
ieee80211_hdr_2addr **)(&pkt), mac, net, type);
+               break;
+       default:
+               printkl(KERN_DEBUG PFX "Unsupported Control Frame type: %i\=
n",=20
type);
+               return -EINVAL;
+       }
+
+       if(pkt_size =3D=3D 0)
+               return -ENOMEM;
+
+       /* Send the packet to the ieee80211 layer for tx */
+       ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *) pkt, pkt_siz=
e);
+
+       kfree(pkt);
+       return 0;
+}

=2D-=20
MfG/Sincerely
Toralf F=F6rster

--nextPart3055047.fcpR84OWpo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEcwP3hyrlCH22naMRAgMkAJ9Zc8kkYG9G9L6apZ4qnj2LUM6dLACgpKQA
d/ADmFWp4zWvZacF0kkLLbg=
=e5x1
-----END PGP SIGNATURE-----

--nextPart3055047.fcpR84OWpo--
