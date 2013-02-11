From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 0/2] netpoll: Cleanup netpoll locking and sparse warnings
Date: Mon, 11 Feb 2013 15:25:29 -0500
Message-ID: <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, fengguang.wu@intel.com,
	eric.dumazet@gmail.com, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35202 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758813Ab3BKU0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 15:26:20 -0500
In-Reply-To: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was fixing some sparse warnings in netpoll from a previous commit, and it was
pointed out to me that one of the rcu_dereferences that I fixed up in 
__netpoll_cleanup might not have been correct.  On investigation I found that 
rtnl_dereference should have been the correct macro to use, but we had a path in
which we weren't properly holding the rtnl lock.  This patch series fixes up the
locking in the __netpoll_free_rcu path, and then properly corrects the sparse 
warnings in the netpoll.c file that I previously introduced.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: David Miller <davem@davemloft.net>
CC: fengguang.wu@intel.com
CC: eric.dumazet@gmail.com
CC: Cong Wang <amwang@redhat.com>
