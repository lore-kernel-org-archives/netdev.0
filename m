From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] macvtap: fix warning due to use of uninitialised var
Date: Tue, 20 Sep 2011 11:48:11 +0100
Message-ID: <1316515691-1833-1-git-send-email-ian.campbell@citrix.com>
References: <20110920091724.GA11100@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58014 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409Ab1ITKt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 06:49:27 -0400
In-Reply-To: <20110920091724.GA11100@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

d1b08284ade "macvtap: convert to SKB paged frag API." accidentally drop=
ped the
initialisation of a variable leading to:
	drivers/net/macvtap.c:509:5: warning: =E2=80=98f=E2=80=99 may be used =
uninitialized
		in this function [-Wuninitialized]

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/macvtap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7c3f84a..5beda89 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -503,6 +503,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *s=
kb, const struct iovec *from,
 		skb->truesize +=3D len;
 		atomic_add(len, &skb->sk->sk_wmem_alloc);
 		while (len) {
+			f =3D &skb_shinfo(skb)->frags[i];
 			__skb_fill_page_desc(
 				skb, i, page[i],
 				base & ~PAGE_MASK,
--=20
1.7.2.5
