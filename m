From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 03/10] tun: Use POLLERR not EBADF in tun_chr_poll
Date: Tue, 20 Jan 2009 12:59:05 -0800
Message-ID: <m1hc3tlmna.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56267 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755456AbZAUCpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:15 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out02.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5f-00015N-Ct
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:15 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5f-00054H-0R
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:15 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jGoR029105
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:16 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jG0H029104
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:16 -0800
In-Reply-To: <m1mydllmpf.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 12\:57\:48 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


EBADF is meaningless in the context of a poll mask so use POLLERR
instead.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 20ef14d..8743de9 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -382,7 +382,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	unsigned int mask = POLLOUT | POLLWRNORM;
 
 	if (!tun)
-		return -EBADFD;
+		return POLLERR;
 
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
-- 
1.5.6.3
