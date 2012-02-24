From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 24 Feb 2012 14:49:26 -0500 (EST)
Message-ID: <20120224.144926.1896492725127004622.davem@davemloft.net>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2BXTtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 14:49:31 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 24 Feb 2012 02:12:53 -0800

> The following are changes since commit 7c3a95a15ad2a5278498a72df0463131048926a3:
>   davinci_mdio: Correct bitmask for clock divider value
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Applied, but I had to add the following patch on top for completeness.

--------------------
net: Add missing getsockopt for SO_NOFCS.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/sock.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 55011cb..216719c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1035,6 +1035,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 		v.val = sk->sk_peek_off;
 		break;
+	case SO_NOFCS:
+		v.val = !!sock_flag(sk, SOCK_NOFCS);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.7.7.6
