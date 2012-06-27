From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -resend] 9p: fix min_t() casting in p9pdu_vwritef()
Date: Wed, 27 Jun 2012 12:01:41 +0300
Message-ID: <20120627090141.GF31212@elgon.mountain>
References: <20120627085800.GA3007@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120627085800.GA3007@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think we're actually likely to hit this limit but if we do
then the comparison should be done as size_t.  The original code
is equivalent to:
        len = strlen(sptr) % USHRT_MAX;

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I was told this patch "has already made it upstream via the v9fs pull."
but it must have been dropped accidentally.  Originally sent on Sat,
Jan 15, 2011.

diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 9ee48cb..3d33ecf 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -368,7 +368,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				const char *sptr = va_arg(ap, const char *);
 				uint16_t len = 0;
 				if (sptr)
-					len = min_t(uint16_t, strlen(sptr),
+					len = min_t(size_t, strlen(sptr),
 								USHRT_MAX);
 
 				errcode = p9pdu_writef(pdu, proto_version,
