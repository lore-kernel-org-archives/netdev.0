From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS control message
Date: Wed, 27 Feb 2013 11:43:51 -0800
Message-ID: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:62714 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3B0Tn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 14:43:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building sctp may fail with:

In function =E2=80=98copy_from_user=E2=80=99,
    inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
    net/sctp/socket.c:5656:20:
arch/x86/include/asm/uaccess_32.h:211:26: error: call to
    =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribute e=
rror: copy_from_user()
    buffer size is not provably correct

if built with W=3D1 due to a missing parameter size validation.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/sctp/socket.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index cedd9bf..0a5f2bf 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5652,6 +5652,8 @@ static int sctp_getsockopt_assoc_stats(struct soc=
k *sk, int len,
 	/* User must provide at least the assoc id */
 	if (len < sizeof(sctp_assoc_t))
 		return -EINVAL;
+	if (len > sizeof(struct sctp_assoc_stats))
+		len =3D sizeof(struct sctp_assoc_stats);
=20
 	if (copy_from_user(&sas, optval, len))
 		return -EFAULT;
--=20
1.7.9.7
