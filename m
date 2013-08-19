From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/4] tun: Report whether the queue is attached or not
Date: Mon, 19 Aug 2013 19:09:56 +0400
Message-ID: <52123544.30700@parallels.com>
References: <52123515.3060507@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:53411 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3HSPJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:09:57 -0400
In-Reply-To: <52123515.3060507@parallels.com>
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
index a12450b..167222f 100644
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
