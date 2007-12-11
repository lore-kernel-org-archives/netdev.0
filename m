From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Mon, 10 Dec 2007 21:04:07 -0700
Message-ID: <m1lk8127yg.fsf@ebiederm.dsl.xmission.com>
References: <20071210163645.GA24030@iris.sw.ru> <475D7849.3030206@fr.ibm.com>
	<475D7C56.9020402@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54889 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbXLKEGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 23:06:55 -0500
In-Reply-To: <475D7C56.9020402@sw.ru> (Kirill Korotaev's message of "Mon, 10
	Dec 2007 20:50:14 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kirill Korotaev <dev@sw.ru> writes:

> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>> 
>>>Recently David Miller and Herbert Xu pointed out that struct net becomes
>>>overbloated and un-maintainable. There are two solutions:
>>>- provide a pointer to a network subsystem definition from struct net.
>>>  This costs an additional dereferrence
>>>- place sub-system definition into the structure itself. This will speedup
>>>  run-time access at the cost of recompilation time
>>>
>>>The second approach looks better for us. 
>> 
>> 
>> Yes, we do not need/want a pointer in this structure and add more 
>> dereference in the network code.

If it does go that way we just carefully pass around a properly
typed structure in that subsystem to reduce the cost.  Still 
it would be nice not to need to add the extra pointer.

>>>index b62e31f..f60e1ce 100644
>>>--- a/include/net/net_namespace.h
>>>+++ b/include/net/net_namespace.h
>>>@@ -8,6 +8,8 @@
>>> #include <linux/workqueue.h>
>>> #include <linux/list.h>
>>>
>>>+#include <net/netns/unix.h>
>>>+
>>> struct proc_dir_entry;
>>> struct net_device;
>>> struct sock;
>>>@@ -46,8 +48,7 @@ struct net {
>>> 	struct hlist_head	packet_sklist;
>>>
>>> 	/* unix sockets */
>>>-	int			sysctl_unix_max_dgram_qlen;
>>>-	struct ctl_table_header	*unix_ctl;
>>>+	struct netns_unix	unx;
>> 
>> 
>> Can you change this from unx to unix ?
>
> no, it won't compile. Guess why :)

Hmm.  It looks like it is a #define somewhere gcc?
Eric
