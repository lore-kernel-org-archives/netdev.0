From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netdev: set __percpu attribute on
 netdev_alloc_pcpu_stats
Date: Mon, 10 Mar 2014 09:41:46 -0700
Message-ID: <20140310094146.2aaa8e0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57781 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbaCJQlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:41:53 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so7252418pdi.7
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:41:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes sparse warnings in vlan driver.
It propagates the sparse __percpu attribute from alloc_percpu
into netdev_alloc_pcpu_stats. I expect it may trigger additional
sparse warnings from other drivers that are missing the __percpu
attribute.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/linux/netdevice.h	2014-03-03 10:37:53.282147105 -0800
+++ b/include/linux/netdevice.h	2014-03-10 09:32:48.599837500 -0700
@@ -1812,7 +1812,7 @@ struct pcpu_sw_netstats {
 
 #define netdev_alloc_pcpu_stats(type)				\
 ({								\
-	typeof(type) *pcpu_stats = alloc_percpu(type);		\
+	typeof(type) __percpu *pcpu_stats = alloc_percpu(type); \
 	if (pcpu_stats)	{					\
 		int i;						\
 		for_each_possible_cpu(i) {			\
