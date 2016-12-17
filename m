From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn: use designated initializers
Date: Fri, 16 Dec 2016 17:01:42 -0800
Message-ID: <20161217010142.GA140401@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Antonio Quartulli <a@unstable.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/i4l/isdn_concap.c   |  6 +++---
 drivers/isdn/i4l/isdn_x25iface.c | 16 ++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_concap.c b/drivers/isdn/i4l/isdn_concap.c
index 91d57304d4d3..336523ec077c 100644
--- a/drivers/isdn/i4l/isdn_concap.c
+++ b/drivers/isdn/i4l/isdn_concap.c
@@ -80,9 +80,9 @@ static int isdn_concap_dl_disconn_req(struct concap_proto *concap)
 }
 
 struct concap_device_ops isdn_concap_reliable_dl_dops = {
-	&isdn_concap_dl_data_req,
-	&isdn_concap_dl_connect_req,
-	&isdn_concap_dl_disconn_req
+	.data_req = &isdn_concap_dl_data_req,
+	.connect_req = &isdn_concap_dl_connect_req,
+	.disconn_req = &isdn_concap_dl_disconn_req
 };
 
 /* The following should better go into a dedicated source file such that
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index 0c5d8de41b23..ba60076e0b95 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -53,14 +53,14 @@ static int isdn_x25iface_disconn_ind(struct concap_proto *);
 
 
 static struct concap_proto_ops ix25_pops = {
-	&isdn_x25iface_proto_new,
-	&isdn_x25iface_proto_del,
-	&isdn_x25iface_proto_restart,
-	&isdn_x25iface_proto_close,
-	&isdn_x25iface_xmit,
-	&isdn_x25iface_receive,
-	&isdn_x25iface_connect_ind,
-	&isdn_x25iface_disconn_ind
+	.proto_new = &isdn_x25iface_proto_new,
+	.proto_del = &isdn_x25iface_proto_del,
+	.restart = &isdn_x25iface_proto_restart,
+	.close = &isdn_x25iface_proto_close,
+	.encap_and_xmit = &isdn_x25iface_xmit,
+	.data_ind = &isdn_x25iface_receive,
+	.connect_ind = &isdn_x25iface_connect_ind,
+	.disconn_ind = &isdn_x25iface_disconn_ind
 };
 
 /* error message helper function */
-- 
2.7.4


-- 
Kees Cook
Nexus Security
