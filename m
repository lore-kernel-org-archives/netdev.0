From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange Panic (Deadlock)
Date: Wed, 26 Dec 2007 19:58:22 +0100
Message-ID: <20071226185822.GC3061@ami.dom.local>
References: <476FCC41.8070202@bigtelecom.ru> <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru> <47701542.9010806@gmail.com> <4770C956.5040409@bigtelecom.ru> <20071226185411.GA3061@ami.dom.local> <20071226185642.GB3061@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:35048 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbXLZS41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 13:56:27 -0500
Received: by nf-out-0910.google.com with SMTP id g13so163046nfb.21
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2007 10:56:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071226185642.GB3061@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 26, 2007 at 07:56:42PM +0100, Jarek Poplawski wrote:
...

[PATCH 3/3] (for testing only)
---

diff -Nurp linux-2.6.23.12-/net/sched/sch_api.c linux-2.6.23.12+/net/sched/sch_api.c
--- linux-2.6.23.12-/net/sched/sch_api.c	2007-12-21 22:26:15.000000000 +0100
+++ linux-2.6.23.12+/net/sched/sch_api.c	2007-12-26 13:35:46.000000000 +0100
@@ -514,8 +514,11 @@ qdisc_create(struct net_device *dev, u32
 				 * a ops->reset() here? The qdisc was never
 				 * in action so it shouldn't be necessary.
 				 */
-				if (ops->destroy)
+				if (ops->destroy) {
+					qdisc_lock_tree(dev);
 					ops->destroy(sch);
+					qdisc_unlock_tree(dev);
+				}
 				goto err_out3;
 			}
 		}
