From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Mon, 10 Dec 2007 20:50:14 +0300
Message-ID: <475D7C56.9020402@sw.ru>
References: <20071210163645.GA24030@iris.sw.ru> <475D7849.3030206@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, containers@lists.osdl.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:14680 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172AbXLJRou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 12:44:50 -0500
In-Reply-To: <475D7849.3030206@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
> 
>>Recently David Miller and Herbert Xu pointed out that struct net becomes
>>overbloated and un-maintainable. There are two solutions:
>>- provide a pointer to a network subsystem definition from struct net.
>>  This costs an additional dereferrence
>>- place sub-system definition into the structure itself. This will speedup
>>  run-time access at the cost of recompilation time
>>
>>The second approach looks better for us. 
> 
> 
> Yes, we do not need/want a pointer in this structure and add more 
> dereference in the network code.
> 
> 
>>Other sub-systems will be converted
>>to this approach if this will be accepted :)
>>
>>Signed-off-by: Denis V. Lunev <den@openvz.org>
>>---
>>diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
>>index b62e31f..f60e1ce 100644
>>--- a/include/net/net_namespace.h
>>+++ b/include/net/net_namespace.h
>>@@ -8,6 +8,8 @@
>> #include <linux/workqueue.h>
>> #include <linux/list.h>
>>
>>+#include <net/netns/unix.h>
>>+
>> struct proc_dir_entry;
>> struct net_device;
>> struct sock;
>>@@ -46,8 +48,7 @@ struct net {
>> 	struct hlist_head	packet_sklist;
>>
>> 	/* unix sockets */
>>-	int			sysctl_unix_max_dgram_qlen;
>>-	struct ctl_table_header	*unix_ctl;
>>+	struct netns_unix	unx;
> 
> 
> Can you change this from unx to unix ?

no, it won't compile. Guess why :)

> If you encapsulate the structure definitions per subsystem, you can drop 
> the unix prefix in the variable declaration.
> 
> Instead of having:
> 	netns->unix->unix_ctl
> you will have:
> 	netns->unix->ctl

agree.

Kirill
