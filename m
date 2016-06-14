From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 0/3] macsec fixes
Date: Tue, 14 Jun 2016 15:25:13 +0200
Message-ID: <cover.1465908271.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbcFNNZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:25:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 adds rcu_barrier() during module unload to prevent possible
panics.

Patch 2 allocates memory for scattergather lists and the IV on the
heap, since they can escape the current function's context during
crypto callbacks.

Patch 3 fixes a failure to create secure associations.

Sabrina Dubroca (3):
  macsec: add rcu_barrier() on module exit
  macsec: allocate sg and iv on the heap
  macsec: fix SA initialization

 drivers/net/macsec.c | 49 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 39 insertions(+), 10 deletions(-)

-- 
2.8.3
