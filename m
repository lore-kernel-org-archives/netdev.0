From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 0/2] fix "ip link show dev ..." for NICs with many VFs
Date: Fri,  1 Sep 2017 18:39:06 +0200 (CEST)
Message-ID: <cover.1504283683.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two of our customers recently encountered problems with processing of large
messages produced by kernel in response to "ip link show" for NICs with
many (120-128) virtual functions. While some of them have been already
addressed in recent versions of iproute2, some still persist.

Patch 1 adds check to handle the case when a message fits into the
buffer in rtnl_talk() but not into the buffer in iplink_get().

Patch 2 increases the buffer size in iplink_get() to suffice even for
NICs with 128 VFs. 

Note: after applying patch 2, patch 1 seems useless as both buffers have
the same size so that the check cannot actually trigger. However, as we
cannot guarantee they will always stay the same, I believe the check
should still be added.

Michal Kubecek (2):
  iplink: check for message truncation in iplink_get()
  iplink: double the buffer size also in iplink_get()

 ip/iplink.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

-- 
2.14.1
