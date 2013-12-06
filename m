From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_memcontrol: Cleanup/fix cg_proto->memory_pressure
 handling.
Date: Thu, 05 Dec 2013 21:01:22 -0500 (EST)
Message-ID: <20131205.210122.1665109336067593941.davem@davemloft.net>
References: <20131204222943.GC21724@cmpxchg.org>
	<20131204.175028.1602944177771517327.davem@davemloft.net>
	<87mwkg542z.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@cmpxchg.org, glommer@gmail.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@kvack.org
To: ebiederm@xmission.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <87mwkg542z.fsf_-_@xmission.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 04 Dec 2013 20:12:04 -0800

> 
> kill memcg_tcp_enter_memory_pressure.  The only function of
> memcg_tcp_enter_memory_pressure was to reduce deal with the
> unnecessary abstraction that was tcp_memcontrol.  Now that struct
> tcp_memcontrol is gone remove this unnecessary function, the
> unnecessary function pointer, and modify sk_enter_memory_pressure to
> set this field directly, just as sk_leave_memory_pressure cleas this
> field directly.
> 
> This fixes a small bug I intruduced when killing struct tcp_memcontrol
> that caused memcg_tcp_enter_memory_pressure to never be called and
> thus failed to ever set cg_proto->memory_pressure.
> 
> Remove the cg_proto enter_memory_pressure function as it now serves
> no useful purpose.
> 
> Don't test cg_proto->memory_presser in sk_leave_memory_pressure before
> clearing it.  The test was originally there to ensure that the pointer
> was non-NULL.  Now that cg_proto is not a pointer the pointer does not
> matter.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
