From: jamal <hadi@cyberus.ca>
Subject: [PATCH] [IPSEC]: pfkey should ignore events when no listeners
Date: Sat, 07 Jun 2008 09:23:10 -0400
Message-ID: <1212844990.4615.68.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-bDDUkruPqiT3+lD2xKeQ"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:12180 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbYFGNXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 09:23:15 -0400
Received: by wr-out-0506.google.com with SMTP id c48so771693wra.1
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2008 06:23:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bDDUkruPqiT3+lD2xKeQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I have only tested with SAs but i expect similar results with SPs.

cheers,
jamal

--=-bDDUkruPqiT3+lD2xKeQ
Content-Disposition: attachment; filename=pfkey-perf
Content-Type: text/plain; name=pfkey-perf; charset=us-ascii
Content-Transfer-Encoding: 7bit

[IPSEC]: pfkey should ignore events when no listeners

When pfkey has no km listeners, it still does a lot of work
before finding out there aint nobody out there.
If a tree falls in a forest and no one is around to hear it, does it make
a sound? In this case it makes a lot of noise:
With this short-circuit adding 10s of thousands of SAs using
netlink improves performance by ~10%.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit ad610c01e537679b1529c6f6c026a95a4e694dd2
tree 9c9ccda8b8a55aa29ba632d8ca6e1de5964c4c65
parent aab2545fdd6641b76af0ae96456c4ca9d1e50dad
author Jamal Hadi Salim <hadi@cyberus.ca> Sat, 07 Jun 2008 09:19:09 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sat, 07 Jun 2008 09:19:09 -0400

 net/key/af_key.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9bba7ac..7470e36 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3030,6 +3030,9 @@ static int key_notify_sa_expire(struct xfrm_state *x, struct km_event *c)
 
 static int pfkey_send_notify(struct xfrm_state *x, struct km_event *c)
 {
+	if (atomic_read(&pfkey_socks_nr) == 0)
+		return 0;
+
 	switch (c->event) {
 	case XFRM_MSG_EXPIRE:
 		return key_notify_sa_expire(x, c);

--=-bDDUkruPqiT3+lD2xKeQ--

