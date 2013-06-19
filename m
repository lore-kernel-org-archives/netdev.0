From: Jerry Chu <hkchu@google.com>
Subject: qlen check in tun.c
Date: Tue, 18 Jun 2013 19:31:48 -0700
Message-ID: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:48428 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933990Ab3FSCbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 22:31:50 -0400
Received: by mail-la0-f49.google.com with SMTP id ea20so4079798lab.8
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 19:31:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tun_net_xmit() the max qlen is computed as
dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
latter may be way too small, forcing one to adjust txqueuelen based
on number of queues created. (Well the default txqueuelen of
500/TUN_READQ_SIZE already seems too small even for single queue.)

Wouldn't it be better to simply use dev->tx_queue_len to cap the qlen of
each queue? This also seems to be more consistent with h/w multi-queues.

Also is there any objection to increase MAX_TAP_QUEUES from 8 to 16?
Yes it will take up more space in struct tun_struct. But we are
hitting the perf limit of 8 queues.

Thanks,

Jerry
