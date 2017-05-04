From: <gregkh@linuxfoundation.org>
Subject: Patch "netlink: Allow direct reclaim for fallback allocation" has been added to the 4.4-stable tree
Date: Thu, 04 May 2017 12:43:33 -0700
Message-ID: <1493927013248191@kroah.com>
References: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: <stable@vger.kernel.org>, <stable-commits@vger.kernel.org>
To: ross.lagerwall@citrix.com, davem@davemloft.net,
        edumazet@google.com, gregkh@linuxfoundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a note to let you know that I've just added the patch titled

    netlink: Allow direct reclaim for fallback allocation

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     netlink-allow-direct-reclaim-for-fallback-allocation.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From ross.lagerwall@citrix.com  Thu May  4 12:37:51 2017
From: Ross Lagerwall <ross.lagerwall@citrix.com>
Date: Wed, 3 May 2017 09:44:19 +0100
Subject: netlink: Allow direct reclaim for fallback allocation
To: <stable@vger.kernel.org>
Cc: Ross Lagerwall <ross.lagerwall@citrix.com>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Message-ID: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>

From: Ross Lagerwall <ross.lagerwall@citrix.com>

The backport of d35c99ff77ec ("netlink: do not enter direct reclaim from
netlink_dump()") to the 4.4 branch (first in 4.4.32) mistakenly removed
direct claim from the initial large allocation _and_ the fallback
allocation which means that allocations can spuriously fail.
Fix the issue by adding back the direct reclaim flag to the fallback
allocation.

Fixes: 6d123f1d396b ("netlink: do not enter direct reclaim from netlink_dump()")
Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

Note that this is only for the 4.4 branch as the regression is only in
this branch. Consequently, there is no corresponding upstream commit.

I'm resending this to the linux-stable list since I now understand the
netdev maintainer only handles backports for the last couple of versions
of Linux.

 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2107,7 +2107,7 @@ static int netlink_dump(struct sock *sk)
 	if (!skb) {
 		alloc_size = alloc_min_size;
 		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
-					(GFP_KERNEL & ~__GFP_DIRECT_RECLAIM));
+					GFP_KERNEL);
 	}
 	if (!skb)
 		goto errout_skb;


Patches currently in stable-queue which might be from ross.lagerwall@citrix.com are

queue-4.4/netlink-allow-direct-reclaim-for-fallback-allocation.patch
