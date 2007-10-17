From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi
	poll
Date: Wed, 17 Oct 2007 12:50:12 +1000
Message-ID: <1192589412.11899.127.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48426 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891AbXJQCuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 22:50:55 -0400
In-Reply-To: <20071016115318.0fc36af3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

napi: use non-interruptible sleep in napi_disable

The current napi_disable() uses msleep_interruptible() but doesn't
(and can't) exit in case there's a signal, thus ending up doing a
hot spin without a cpu_relax. Use uninterruptible sleep instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2007-10-17 12:39:16.000000000 +1000
+++ linux-work/include/linux/netdevice.h	2007-10-17 12:45:00.000000000 +1000
@@ -390,7 +390,7 @@ static inline void napi_complete(struct 
 static inline void napi_disable(struct napi_struct *n)
 {
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
-		msleep_interruptible(1);
+		msleep(1);
 }
 
 /**


