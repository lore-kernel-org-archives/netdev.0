From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Tue, 04 Mar 2014 19:21:52 -0500 (EST)
Message-ID: <20140304.192152.1234652192226780071.davem@davemloft.net>
References: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<20140304.165122.445822929490466603.davem@davemloft.net>
	<87mwh5d1tf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, rgb@redhat.com, eparis@redhat.com,
	linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mwh5d1tf.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 04 Mar 2014 14:41:16 -0800

> If we really want the ability to always appened to the queue of skb's
> is to just have a version of netlink_send_skb that ignores the queued
> limits.  Of course an evil program then could force the generation of
> enough audit records to DOS the kernel, but we seem to be in that
> situation now.  Shrug.

There is never a valid reason to bypass the socket limits.

It protects the system from things going out of control.

Netlink packet sends can fail, and audit should cope with that
event instead of trying to bludgeon it into not happening.
