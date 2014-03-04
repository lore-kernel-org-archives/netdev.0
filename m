From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Tue, 04 Mar 2014 16:51:22 -0500 (EST)
Message-ID: <20140304.165122.445822929490466603.davem@davemloft.net>
References: <874n3ir0uw.fsf_-_@xmission.com>
	<87mwhaplo4.fsf_-_@xmission.com>
	<20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rgb@redhat.com, eparis@redhat.com,
	linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 4 Mar 2014 13:30:04 -0800

> On Fri, 28 Feb 2014 20:50:19 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
>> 
>> Modify audit_send_reply to directly use a non-blocking send and
>> to return an error on failure (if anyone cares).
>> 
>> Modify audit_list_rules_send to use audit_send_reply and give up
>> if we can not send a packet.
>> 
>> Merge audit_list_rules into iaudit_list_rules_send as the code
>> is now sufficiently simple to not justify to callers.
>> 
>> Kill audit_send_list, audit_send_reply_thread because using
>> a separate thread for replies is not needed when sending
>> packets syncrhonously.
> 
> Nothing much seems to be happening here?
> 
> In an earlier email you said "While reading through 3.14-rc1 I found a
> pretty siginficant mishandling of network namespaces in the recent
> audit changes." Were those recent audit changes a post-3.14 thing?  And
> what is the user-visible effect of the mishandling?

I took a quick look at this patch yesterday, and my only suspicion is
that threads are created currently by this code purely to cons up a
blockable context for the netlink code.

Perhaps it wants to avoid any netlink packet drops from being possible.

I'm not so sure.

Anyways, some investigation into perhaps figuring out the intentions of
the original implementation would be nice.
