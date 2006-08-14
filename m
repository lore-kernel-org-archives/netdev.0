From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] rtnetlink notification rework
Date: Mon, 14 Aug 2006 23:37:18 +0200
Message-ID: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:12494 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964937AbWHNVoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:16 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset reworks rtnetlink notifications. Notification logic
is fixed and gets hidden behind nlmsg_notify() and the rtnl socket
is no longer directly accessed. All notification paths get
appropriate error handling. NLM_F_ECHO support is added where it
makes sense and no major surgery is required. Abuses of current->pid
for netlink pids are fixed. An exception is made for users of
rtnetlink_send() which will get converted in a second step as some
bigger code change are required.

