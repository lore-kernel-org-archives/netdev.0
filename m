From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 0/3] macsec: reference counting fixes
Date: Fri, 29 Jul 2016 15:37:52 +0200
Message-ID: <cover.1469782905.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbcG2NiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 09:38:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 adds explicit reference counting on RXSCs, instead of the
current implicit reference counting using the RXSA's refcount.

Patch 2 fixes possible kernel panics during module unload caused by an
RCU callback that schedules another RCU callback, which the
rcu_barrier() added in b196c22af5c3 ("macsec: add rcu_barrier() on
module exit") didn't protect against.

Patch 3 fixes a refcounting issue with the underlying device for a
macsec device when link creation fails.

Sabrina Dubroca (3):
  macsec: fix reference counting on RXSC in macsec_handle_frame
  macsec: RXSAs don't need to hold a reference on RXSCs
  macsec: fix negative refcnt on parent link

 drivers/net/macsec.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

-- 
2.9.0
