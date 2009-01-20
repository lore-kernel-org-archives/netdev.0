From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 09/10] tun: There is no longer any need to deny changing network namespaces
Date: Tue, 20 Jan 2009 13:08:46 -0800
Message-ID: <m1ljt5k7mp.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
	<m1hc3tlmna.fsf_-_@fess.ebiederm.org>
	<m1bpu1lmkn.fsf_-_@fess.ebiederm.org>
	<m17i4plmir.fsf_-_@fess.ebiederm.org>
	<m11vuxlmhn.fsf_-_@fess.ebiederm.org>
	<m1vds9k7vq.fsf_-_@fess.ebiederm.org>
	<m1prihk7p6.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52479 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbZAUCpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:18 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5s-0007Yd-48
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:28 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5h-00054c-Ck
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:17 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jJrp029129
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:19 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jJ8L029128
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:19 -0800
In-Reply-To: <m1prihk7p6.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 13\:07\:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With the awkward case between free_netdev and dev_chr_close fixed
there is no longer any need to limit tun and tap devices to the
network namespace they were created it.  So remove the
NETIF_F_NETNS_LOCAL flag on the network device.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 51dba61..97b0500 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -810,7 +810,6 @@ static void tun_setup(struct net_device *dev)
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = free_netdev;
-	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
 static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
-- 
1.5.6.3
