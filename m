From: Dan Carpenter <error27@gmail.com>
Subject: [patch] 9p: saving negative to unsigned char
Date: Tue, 30 Mar 2010 12:42:09 +0300
Message-ID: <20100330094209.GI5069@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Abhishek Kulkarni <adkulkar@umail.iu.edu>,
	Sripathi Kodi <sripathik@in.ibm.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Venkateswararao Jujjuri <jvrao@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Saving -EINVAL as unsigned char truncates the high bits and changes it 
into 234 instead of -22.  This breaks the test for "if (ret == -EINVAL)"
in parse_opts().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/9p/client.c b/net/9p/client.c
index e3e5bf4..edf31aa 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -71,9 +71,10 @@ inline int p9_is_proto_dotu(struct p9_client *clnt)
 EXPORT_SYMBOL(p9_is_proto_dotu);
 
 /* Interpret mount option for protocol version */
-static unsigned char get_protocol_version(const substring_t *name)
+static int get_protocol_version(const substring_t *name)
 {
-	unsigned char version = -EINVAL;
+	int version = -EINVAL;
+
 	if (!strncmp("9p2000", name->from, name->to-name->from)) {
 		version = p9_proto_legacy;
 		P9_DPRINTK(P9_DEBUG_9P, "Protocol version: Legacy\n");
