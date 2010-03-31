From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Wed, 31 Mar 2010 10:35:29 +0100
Message-ID: <4BB31761.2090906@katalix.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>	<20100330161819.9628.10853.stgit@bert.katalix.com> <20100330093252.60d9cbee@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47252 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933086Ab0CaJgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 05:36:00 -0400
In-Reply-To: <20100330093252.60d9cbee@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 17:18:19 +0100
> James Chapman <jchapman@katalix.com> wrote:
> 
>> +struct l2tp_eth_net {
>> +	struct list_head l2tp_eth_dev_list;
>> +	rwlock_t l2tp_eth_lock;
>> +};
> 
> Reader/write locks are discouraged because they are slower than
> spin locks.  If you have lots of readers use RCU, if reading
> is infrequent just use a spin lock.

Ok. In doing the conversion of the rwlocks in l2tp_core.c, I'm finding
that some list access primitives don't have rcu equivalents, namely
list_is_last(), list_for_each_entry_safe(). Is this intentional? Should
I add the missing ones in a separate patch?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

