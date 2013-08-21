From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/4] tun: Report whether the queue is attached or not
Date: Wed, 21 Aug 2013 14:32:00 +0400
Message-ID: <52149720.7070306@parallels.com>
References: <521496EF.8090909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:50090 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3HUKcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:32:01 -0400
In-Reply-To: <521496EF.8090909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiqueue tun devices allow to attach and detach from its queues
while keeping the interface itself set on file.

Knowing this is critical for the checkpoint part of criu project.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 drivers/net/tun.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4b65fbc..db43a24 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1881,6 +1881,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	case TUNGETIFF:
 		tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
 
+		if (tfile->detached)
+			ifr.ifr_flags |= IFF_DETACH_QUEUE;
+
 		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
 		break;
-- 
1.7.6.5
