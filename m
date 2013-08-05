From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3] macvlan: validate flags
Date: Mon, 5 Aug 2013 18:25:54 +0300
Message-ID: <20130805152554.GA3592@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312Ab3HEPYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 11:24:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit df8ef8f3aaa6692970a436204c4429210addb23a
    macvlan: add FDB bridge ops and macvlan flags
added a flags field to macvlan, which can be
controlled from userspace.
The idea is to make the interface future-proof
so we can add flags and not new fields.

However, flags value isn't validated, as a result,
userspace can't detect which flags are supported.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v2:
	drop chunk in macvlan_common_newlink -
		not necessary since macvlan_validate is always
		called first
Changes from v1:
	tweaked commit message
	no code changes

Please consider this patch for -stable.

The idea is by the time we add more flags,
everyone has updated to a kernel that
detects errors, so userspace will be able
to detect supported flags cleanly.


 drivers/net/macvlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 18373b6..8445a94 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -736,6 +736,10 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EADDRNOTAVAIL;
 	}
 
+	if (data && data[IFLA_MACVLAN_FLAGS] &&
+	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~MACVLAN_FLAG_NOPROMISC)
+		return -EINVAL;
+
 	if (data && data[IFLA_MACVLAN_MODE]) {
 		switch (nla_get_u32(data[IFLA_MACVLAN_MODE])) {
 		case MACVLAN_MODE_PRIVATE:
-- 
MST
