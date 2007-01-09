From: Craig Schlenter <craig@codefountain.com>
Subject: [PATCH] Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during file-transfer
Date: Tue, 9 Jan 2007 07:11:39 +0200
Message-ID: <20070109051139.GA2229@craigdell.detnet.com>
References: <20061230.231952.16573563.yoshfuji@linux-ipv6.org> <20070105054546.953196e5.komurojun-mbn@nifty.com> <20070104122330.GA2233@craigdell.detnet.com> <20070109.102453.32711440.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: komurojun-mbn@nifty.com, bunk@stusta.de, jgarzik@pobox.com,
	viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from myw-stp-196-34-113-243.sentechsa.net ([196.34.113.243]:40005
	"EHLO craigdell.detnet.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751046AbXAIFVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 00:21:17 -0500
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20070109.102453.32711440.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E has suggested =
that I send the patch
below to fix the ftp stalls present in the current kernels.

All credit goes to Komuro <komurojun-mbn@nifty.com> for tracking
this down. The patch is untested but it looks *cough* obviously
correct.

Signed-off-by: Craig Schlenter <craig@codefountain.com>

Thank you!

--Craig

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bf7a224..12de90a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -648,7 +648,7 @@ static void tcp_v4_send_ack(struct tcp_timewait_soc=
k *twsk,
 				   TCPOLEN_TIMESTAMP);
 		rep.opt[1] =3D htonl(tcp_time_stamp);
 		rep.opt[2] =3D htonl(ts);
-		arg.iov[0].iov_len =3D TCPOLEN_TSTAMP_ALIGNED;
+		arg.iov[0].iov_len +=3D TCPOLEN_TSTAMP_ALIGNED;
 	}
=20
 	/* Swap the send and the receive. */
