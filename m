From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v2 4/7] AMSO1100 Memory Management.
Date: Sat, 17 Jun 2006 13:59:12 +1000
Message-ID: <44937E10.3000006@yahoo.com.au>
References: <20060607200646.9259.24588.stgit@stevo-desktop>	 <20060607200655.9259.90768.stgit@stevo-desktop>	 <20060608011744.1a66e85a.akpm@osdl.org> <1150128349.22704.20.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Steve Wise <swise@opengridcomputing.com>, rdreier@cisco.com,
	mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751603AbWFQD7U@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
In-Reply-To: <1150128349.22704.20.camel@trinity.ogc.int>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Tucker wrote:
> On Thu, 2006-06-08 at 01:17 -0700, Andrew Morton wrote:
> 
>>On Wed, 07 Jun 2006 15:06:55 -0500
>>Steve Wise <swise@opengridcomputing.com> wrote:
>>
>>
>>>+void c2_free(struct c2_alloc *alloc, u32 obj)
>>>+{
>>>+	spin_lock(&alloc->lock);
>>>+	clear_bit(obj, alloc->table);
>>>+	spin_unlock(&alloc->lock);
>>>+}
>>
>>The spinlock is unneeded here.
> 
> 
> Good point.

Really?

clear_bit does not give you any memory ordering, so you can have
the situation where another CPU sees the bit cleared, but this
CPU still has stores pending to whatever it is being freed. Or
any number of other nasty memory ordering badness.

I'd just use the spinlocks, and prepend the clear_bit with a
double underscore (so you get the non-atomic version), if that
is appropriate.

The spinlocks nicely handle all the memory ordering issues, and
serve to document concurrency issues. If you need every last bit
of performance and scalability, that's OK, but you need comments
and I suspect you'd need more memory barriers.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
