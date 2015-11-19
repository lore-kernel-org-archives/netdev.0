From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] ppp: Remove PPPOX_ZOMBIE socket state
Date: Thu, 19 Nov 2015 12:52:30 +0100
Message-ID: <cover.1447931252.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Simon Farnsworth <simon@farnz.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42605 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918AbbKSLwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:52:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several issues have been found lately wrt. the PPPOX_ZOMBIE socket
state. This state is now only set upon reception of a PADT to stop
further transmissions. However this is redundant with the PADT
workqueue mechanism introduced by 287f3a943fef ("pppoe: Use workqueue
to die properly when a PADT is received").

We can thus simplify pppox socket state handling by getting rid of
PPPOX_ZOMBIE entirely.


Guillaume Nault (2):
  ppp: don't set sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv()
  ppp: remove PPPOX_ZOMBIE socket state

 drivers/net/ppp/pppoe.c  | 26 ++++----------------------
 drivers/net/ppp/pppox.c  |  2 +-
 include/linux/if_pppox.h |  1 -
 3 files changed, 5 insertions(+), 24 deletions(-)

-- 
2.6.2
