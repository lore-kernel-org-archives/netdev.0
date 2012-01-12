From: Bart Van Assche <bvanassche@acm.org>
Subject: Consequences of commit 16e5726269611b71c930054ffe9b858c1cea88eb
Date: Thu, 12 Jan 2012 19:14:49 +0000
Message-ID: <CAO+b5-pGcKbTYQWdWo=kbiQ2ORbgn8GAV_cfYjGzOARmgrsUxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric Paris <eparis@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39453 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab2ALTOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 14:14:51 -0500
Received: by wgbds12 with SMTP id ds12so2156498wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 11:14:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

If my analysis is correct commit
16e5726269611b71c930054ffe9b858c1cea88eb ("af_unix: dont send
SCM_CREDENTIALS by default") changes the value of
NETLINK_CREDS(skb)->pid from the sender pid into zero. Does that mean
that the code using that construct did work in kernel 3.1 but that it
is broken in kernel 3.2 ? Should that commit be reverted or will
someone fix the code that uses NETLINK_CREDS() ? Would changing
NETLINK_CREDS(skb)->pid into NETLINK_CB(skb).pid be sufficient ?

Thanks,

Bart.

$ git grep 'NETLINK_CREDS([a-zA-Z0-9_]*)->pid'
drivers/scsi/scsi_netlink.c:	pid = NETLINK_CREDS(skb)->pid;
kernel/audit.c:	pid  = NETLINK_CREDS(skb)->pid;
