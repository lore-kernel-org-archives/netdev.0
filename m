Return-Path: <netdev-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:39050 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751671AbdIEMkF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:40:05 -0400
From: Gilad Ben-Yossef <gilad@benyossef.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
        Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
        James Morris <james.l.morris@oracle.com>,
        "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org,
        linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
Subject: [PATCH v8 03/20] net: use -EAGAIN for transient busy indication
Date: Tue,  5 Sep 2017 15:38:42 +0300
Message-Id: <1504615144-29770-4-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace -EBUSY with -EAGAIN when handling transient busy
indication in the absence of backlog.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>

---

Please squash this patch with the previous one when merging upstream.
---
 net/ipv4/ah4.c  | 2 +-
 net/ipv4/esp4.c | 2 +-
 net/ipv6/ah6.c  | 2 +-
 net/ipv6/esp6.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 37db44f..049cb0a 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -240,7 +240,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
+		if (err == -EAGAIN)
 			err = NET_XMIT_DROP;
 		goto out_free;
 	}
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b00e4a4..ff8e088 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -432,7 +432,7 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	case -EINPROGRESS:
 		goto error;
 
-	case -EBUSY:
+	case -EAGAIN:
 		err = NET_XMIT_DROP;
 		break;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 7802b72..ba0c145 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -443,7 +443,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
+		if (err == -EAGAIN)
 			err = NET_XMIT_DROP;
 		goto out_free;
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89910e2..1a71ee5 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -396,7 +396,7 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	case -EINPROGRESS:
 		goto error;
 
-	case -EBUSY:
+	case -EAGAIN:
 		err = NET_XMIT_DROP;
 		break;
 
-- 
2.1.4
