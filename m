From: David Miller <davem@davemloft.net>
Subject: Re: netfilter is not a filesystem
Date: Thu, 10 Feb 2011 14:22:06 -0800 (PST)
Message-ID: <20110210.142206.183039613.davem@davemloft.net>
References: <bug-28862-10286@https.bugzilla.kernel.org/>
	<20110210141119.56d789fc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110210141119.56d789fc.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 10 Feb 2011 14:11:19 -0800

> On Thu, 10 Feb 2011 21:55:26 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=28862
>> 
>>            Summary: /proc/net/ip_conntrack: no space left on device
>>                     systematically
> 
> This is why I'm forever nagging people to not just grab some errno
> because its name happens to sound similar to the error you just detected.
> 
> Yes, it superficially seems nice and logical for netfilter to use
> ENOSPC when it runs out of space.  But when that error code propagates
> up to the user, they see "no space left on device" and will then run
> "df" and wonder what the hell happened to their computer.
> 
> The kernel makes this mistake a *lot*.  EFBIG in the rtc drivers?  Really?

We are in this conundrum because the granularity of errors which can
be indicated by errno signalling is very low.

And one way people handle this is to use all sorts of different types
of errno values to indicate the different cases.

Also, one can argue that it is erroneous for userspace to assume that
error codes are not context dependent.  They most certainly are.
