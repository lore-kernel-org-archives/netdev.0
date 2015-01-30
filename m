From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 11/11] hso: fix rfkill name conflicts
Date: Fri, 30 Jan 2015 13:22:03 +0100
Message-ID: <1422620523-15021-12-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
 <1422620523-15021-3-git-send-email-olivier@sobrie.be>
 <1422620523-15021-4-git-send-email-olivier@sobrie.be>
 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
 <1422620523-15021-6-git-send-email-olivier@sobrie.be>
 <1422620523-15021-7-git-send-email-olivier@sobrie.be>
 <1422620523-15021-8-git-send-email-olivier@sobrie.be>
 <1422620523-15021-9-git-send-email-olivier@sobrie.be>
 <1422620523-15021-10-git-send-email-olivier@sobrie.be>
 <1422620523-15021-11-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-11-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By using only the usb interface number for the rfkill name, we might
have a name conflicts in case two similar hso devices are connected.

In this patch, the name of the hso rfkill interface embed the value
of a counter that is incremented each time a new rfkill interface is
added.

Suggested-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index c14fc80..d31a165 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -153,7 +153,7 @@ struct hso_net {
 	struct hso_device *parent;
 	struct net_device *net;
 	struct rfkill *rfkill;
-	char name[8];
+	char name[24];
 
 	struct usb_endpoint_descriptor *in_endp;
 	struct usb_endpoint_descriptor *out_endp;
@@ -2469,9 +2469,10 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 {
 	struct hso_net *hso_net = dev2net(hso_dev);
 	struct device *dev = &hso_net->net->dev;
+	static u32 rfkill_counter;
 
 	snprintf(hso_net->name, sizeof(hso_net->name), "hso-%d",
-		 interface->altsetting->desc.bInterfaceNumber);
+		 rfkill_counter++);
 
 	hso_net->rfkill = rfkill_alloc(hso_net->name,
 				       &interface_to_usbdev(interface)->dev,
-- 
2.2.0
