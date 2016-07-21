From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH net-next 2/3] rtnl: protect do_setlink from IFLA_XDP_ATTACHED
Date: Wed, 20 Jul 2016 17:22:34 -0700
Message-ID: <1469060555-20250-3-git-send-email-bblanco@plumgrid.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33240 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbcGUAXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:23:08 -0400
Received: by mail-pa0-f52.google.com with SMTP id ks6so23024294pab.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 17:23:08 -0700 (PDT)
In-Reply-To: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IFLA_XDP_ATTACHED nested attribute is meant for read-only, and while
do_setlink properly ignores it, it should be more paranoid and reject
commands that try to set it.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 net/core/rtnetlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eba2b82..189cc78 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2109,6 +2109,10 @@ static int do_setlink(const struct sk_buff *skb,
 		if (err < 0)
 			goto errout;
 
+		if (xdp[IFLA_XDP_ATTACHED]) {
+			err = -EINVAL;
+			goto errout;
+		}
 		if (xdp[IFLA_XDP_FD]) {
 			err = dev_change_xdp_fd(dev,
 						nla_get_s32(xdp[IFLA_XDP_FD]));
-- 
2.8.2
