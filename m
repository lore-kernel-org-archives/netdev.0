From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next 0/2] Address reference counting issues with
 sock_queue_err_skb
Date: Wed, 10 Sep 2014 18:04:42 -0400
Message-ID: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	eric.dumazet@gmail.com, linville@tuxdriver.com
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14767 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535AbaIJWNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 18:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After looking over the code for skb_clone_sk after some comments made by
Eric Dumazet I have come to the conclusion that skb_clone_sk is taking the
correct approach in how to handle the sk_refcnt when creating a buffer that
is eventually meant to be returned to the socket via the sock_queue_err_skb
function.

However upon review of other callers I found what I believe to be a
possible reference count issue in the path for handling "wifi ack" packets.
To address this I have applied the same logic that is currently in place so
that the sk_refcnt will be forced to stay at least 1, or we will not
provide an skb to return in the sk_error_queue.

---

Alexander Duyck (2):
      skb: Add documentation for skb_clone_sk
      mac80211: Resolve sk_refcnt/sk_wmem_alloc issue in wifi ack path


 net/core/skbuff.c |   18 ++++++++++++++++++
 net/mac80211/tx.c |   15 ++++-----------
 2 files changed, 22 insertions(+), 11 deletions(-)

-- 
