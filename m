From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/2] qdisc: fix build with !CONFIG_NET_SCHED
Date: Sat, 31 Aug 2013 10:15:33 -0700
Message-ID: <20130831101533.6cb8e452@nehalam.linuxnetplumber.net>
References: <20130831100442.60c99dc8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:40845 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab3HaRRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 13:17:50 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so3543876pab.26
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 10:17:50 -0700 (PDT)
In-Reply-To: <20130831100442.60c99dc8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiqueue scheduler refers to default_qdisc_ops; therefore the
variable definition needs to be moved to handle case where net
scheduler API is not available.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/sched/sch_api.c	2013-08-31 09:40:20.949205839 -0700
+++ b/net/sched/sch_api.c	2013-08-31 10:01:45.811672724 -0700
@@ -131,11 +131,6 @@ static DEFINE_RWLOCK(qdisc_mod_lock);
  ************************************************/
 
 
-/* Qdisc to use by default */
-
-const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
-EXPORT_SYMBOL(default_qdisc_ops);
-
 /* The list of all installed queueing disciplines. */
 
 static struct Qdisc_ops *qdisc_base;
--- a/net/sched/sch_generic.c	2013-08-31 09:50:18.313178455 -0700
+++ b/net/sched/sch_generic.c	2013-08-31 10:02:10.699323182 -0700
@@ -30,6 +30,10 @@
 #include <net/pkt_sched.h>
 #include <net/dst.h>
 
+/* Qdisc to use by default */
+const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
+EXPORT_SYMBOL(default_qdisc_ops);
+
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
