From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH v2] net/sctp/ulpevent.c: Deinline sctp_ulpevent_set_owner, save 1616 bytes
Date: Wed, 21 Jun 2017 19:03:27 +0200
Message-ID: <20170621170327.4873-1-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function compiles to 147 bytes of machine code. 13 callsites.

I'm no expert on SCTP events, but quick reading of SCTP docs tells me that
SCTP events are not happening on every packet.
They are ASSOC_CHANGE, PEER_ADDR_CHANGE, REMOTE_ERROR and such.
Does not look performance critical.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: Neil Horman <nhorman@tuxdriver.com>
CC: David Miller <davem@davemloft.net>
CC: linux-sctp@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
Changed since v1:
* reindented function argument list

 net/sctp/ulpevent.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index ec2b3e0..bc3f495 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -88,8 +88,8 @@ int sctp_ulpevent_is_notification(const struct sctp_ulpevent *event)
 /* Hold the association in case the msg_name needs read out of
  * the association.
  */
-static inline void sctp_ulpevent_set_owner(struct sctp_ulpevent *event,
-					   const struct sctp_association *asoc)
+static void sctp_ulpevent_set_owner(struct sctp_ulpevent *event,
+				    const struct sctp_association *asoc)
 {
 	struct sctp_chunk *chunk = event->chunk;
 	struct sk_buff *skb;
-- 
1.8.3.1
