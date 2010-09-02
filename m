From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_cgroup: Fix rcu lockdep warning
Date: Thu, 02 Sep 2010 10:05:51 -0700 (PDT)
Message-ID: <20100902.100551.115929058.davem@davemloft.net>
References: <4C7F446F.8040303@cn.fujitsu.com>
	<1283423916.2059.1847.camel@laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizf@cn.fujitsu.com, herbert@gondor.hengli.com.au,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596Ab0IBRFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 13:05:35 -0400
In-Reply-To: <1283423916.2059.1847.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 02 Sep 2010 12:38:36 +0200

> On Thu, 2010-09-02 at 14:30 +0800, Li Zefan wrote:
>> Calling task_subsys_state() without holding rcu_read_lock or
>> cgroup_mutex can cause lockdep warning.
>> 
> 
> That is not a suitable changelog.
> 
> Was the warning correct? Is your patch correct? What does RCU protect
> here and why can we use classid after dropping it.
> 
> Simply frobbing code to make the warning go away is not good.

In fact shouldn't this be a rcu_dereference() or similar?
