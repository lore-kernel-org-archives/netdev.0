From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Wed, 20 Apr 2016 20:30:39 -0400
Message-ID: <66816.1461198639@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461198639_3237P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:59987 "EHLO
	omr1.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751279AbcDUAap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 20:30:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1461198639_3237P
Content-Type: text/plain; charset=us-ascii

linux-next 20160420 is whining at an incredible rate - in 20 minutes of
uptime, I piled up some 41,000 hits from all over the place (cleaned up
to skip the CPU and PID so the list isn't quite so long):

% grep include/net/sock.h /var/log/messages | cut -f5- -d: |  sed -e 's/PID: [0-9]* /PID: (elided) /' -e 's/CPU: [0-3]/CPU: +/' | sort | uniq -c | sort -nr
  13468  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_v6_rcv+0xc20/0xcb0
   9770  CPU: + PID: (elided) at include/net/sock.h:1408 udp_queue_rcv_skb+0x3ca/0x6d0
   7706  CPU: + PID: (elided) at include/net/sock.h:1408 sock_owned_by_user+0x91/0xa0
   2818  CPU: + PID: (elided) at include/net/sock.h:1408 udpv6_queue_rcv_skb+0x3b6/0x6d0
   1981  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_write_timer+0xf2/0x110
   1954  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_delack_timer+0x110/0x130
   1912  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_keepalive_timer+0x136/0x2c0
    882  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_close+0x226/0x4f0
    804  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_tasklet_func+0x192/0x1e0
     28  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_child_process+0x17a/0x350
      2  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_v6_err+0x401/0x660
      2  CPU: + PID: (elided) at include/net/sock.h:1408 tcp_v6_err+0x1fd/0x660

Seems to be from this commit, which is apparently over-stringent or
isn't handling some case correctly:

commit fafc4e1ea1a4c1eb13a30c9426fb799f5efacbc3
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Fri Apr 8 15:11:27 2016 +0200

    sock: tigthen lockdep checks for sock_owned_by_user

    sock_owned_by_user should not be used without socket lock held. It seems
    to be a common practice to check .owned before lock reclassification, so
    provide a little help to abstract this check away.

    Cc: linux-cifs@vger.kernel.org
    Cc: linux-bluetooth@vger.kernel.org
    Cc: linux-nfs@vger.kernel.org
    Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


--==_Exmh_1461198639_3237P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVxgfLgdmEQWDXROgAQLfVhAApJUOcQtJpVr5umASsvKeM3BDbFmwS8kT
IEsZRNi6Inv0zVB4s7vnGI58mjWP22snAp1D0Ip7V/Z6FhdRS50OOk/6o+GQ1duK
HntSZP7T3YAqtb1+WO0ufReh1JKFGNtAZ2UZvzN0bPKSmkRP9KJAY2KDkSwXeeEP
qmxyqCuG9XKAP0SRHqJ4bpo/BeXj2Ae5JVzXABR54MxyexPo+oZXf/uwNwi3Tc5V
gA108kj1sYt+x/A42DbRxAZ6nviRyZ8cOa7WXfzFIAD6XFZeQn81zX53uxnnNPhF
SrCaIigMszxO8pu7SKJyfKtAcuKrl+jODwWejMkWnoJx0i2vdMhOFI6LDHjIoJZo
rG5usi4xFensTnoaAJYPQ8sXXud8BUzmPqRhaRJcapA649EWv2oLyE6N63LZHM7B
G8COVR+CvSpKRLTdr+JvNMhAToAel2cA+hoBUnYTg5B4k2cU0a2IxTcRTj8ceIAZ
vbX7p+9d8U88V81FTnZTEctK60MdDW1IamXix9VF/Pcv0ECDmzNDAPDddx5oOtcO
VnPCWRGtsK976SGjgHx7fPeArbLZ5AEfRWxD0U6v2v+zvkOQj8GVs69dA2cZs488
LcCIZt98ULox26Useu45hzbYS/vE1slfU7xSRpSaSHQillBCTz0yE78o/DFTOpeu
O4HPuoadlp8=
=eUi5
-----END PGP SIGNATURE-----

--==_Exmh_1461198639_3237P--
