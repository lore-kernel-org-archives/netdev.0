From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix net.ipv6.conf.all interface DAD handlers
Date: Fri, 15 Sep 2017 14:12:27 -0700 (PDT)
Message-ID: <20170915.141227.723470226137757556.davem@davemloft.net>
References: <20170912154637.12996-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org, ek@google.com
To: mcroce@redhat.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170912154637.12996-1-mcroce@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matteo Croce <mcroce@redhat.com>
Date: Tue, 12 Sep 2017 17:46:37 +0200

> Currently, writing into
> net.ipv6.conf.all.{accept_dad,use_optimistic,optimistic_dad} has no effect.
> Fix handling of these flags by:
> 
> - using the maximum of global and per-interface values for the
>   accept_dad flag. That is, if at least one of the two values is
>   non-zero, enable DAD on the interface. If at least one value is
>   set to 2, enable DAD and disable IPv6 operation on the interface if
>   MAC-based link-local address was found
> 
> - using the logical OR of global and per-interface values for the
>   optimistic_dad flag. If at least one of them is set to one, optimistic
>   duplicate address detection (RFC 4429) is enabled on the interface
> 
> - using the logical OR of global and per-interface values for the
>   use_optimistic flag. If at least one of them is set to one,
>   optimistic addresses won't be marked as deprecated during source address
>   selection on the interface.
> 
> While at it, as we're modifying the prototype for ipv6_use_optimistic_addr(),
> drop inline, and let the compiler decide.
> 
> Fixes: 7fd2561e4ebd ("net: ipv6: Add a sysctl to make optimistic addresses useful candidates")
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Erik, please review.
