From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/3] Three possible UDP fixes.
Date: Tue, 21 Jun 2011 16:43:37 -0400
Message-ID: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58213 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756933Ab1FUUny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were originally found on a 2.6.34 baseline, but I looked
at them and couldn't see any reason why they wouldn't be valid
fixes on net-next.  But I'll feel better when someone like
Dave and/or Eric sanity checks them too.

There was one thing that was a consideration.  In the 3rd patch,
where we clear MSG_TRUNC bit -- is there anything in there that
we really need to be concerned about preserving on the retry,
or could we just unconditionally do "msg->msg_flags = 0" ?
I wasn't sure, and so sticking with clearing the offending bit
seemed like the most cautious approach.

Thanks,
Paul.

---

Mark Asselstine (1):
  net: ipv4: fix potential memory leak by assigning uhash_entries

Xufeng Zhang (2):
  ipv6/udp: Use the correct variable to determine non-blocking condition
  udp/recvmsg: Clear MSG_TRUNC flag when starting over for a new packet

 net/ipv4/udp.c |    5 ++++-
 net/ipv6/udp.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
1.7.4.4

