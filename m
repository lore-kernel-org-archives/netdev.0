From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] bpa10x: free sk_buff with kfree_skb
Date: Wed, 29 Oct 2008 22:05:14 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810271821340.7072@wrl-59.cs.helsinki.fi>
References: <20081026.232626.97216182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-2996575-1225197957=:7072"
Cc: Netdev <netdev@vger.kernel.org>, marcel@holtmann.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46139 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbYJ2UFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:05:17 -0400
In-Reply-To: <20081026.232626.97216182.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0810292159110.7952@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2996575-1225197957=:7072
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810292159111.7952@wrl-59.cs.helsinki.fi>

On Sun, 26 Oct 2008, David Miller wrote:

> 2) Couple places trying to pass sk_buff to kfree() instead of
>    kfree_skb().  Fixed by Sergio Luis

I tried with coccinelle and found one more of these, though my
other attempts with it haven't been all that successful... 


--
[PATCH] bpa10x: free sk_buff with kfree_skb

Inspired by Sergio Luis' similar patches, I finally found
a case which is trivial enough that spatch won't choke
on it.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/bluetooth/bpa10x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index 32f3a8e..b936d8c 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -443,8 +443,8 @@ static void bpa10x_destruct(struct hci_dev *hdev)
 
 	BT_DBG("%s", hdev->name);
 
-	kfree(data->rx_skb[0]);
-	kfree(data->rx_skb[1]);
+	kfree_skb(data->rx_skb[0]);
+	kfree_skb(data->rx_skb[1]);
 	kfree(data);
 }
 
-- 
1.5.2.2
---696208474-2996575-1225197957=:7072--
