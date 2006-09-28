From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Wed, 27 Sep 2006 22:44:44 -0700 (PDT)
Message-ID: <20060927.224444.109879330.davem@davemloft.net>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9425
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965279AbWI1Foo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 01:44:44 -0400
To: yoshfuji@linux-ipv6.org, tgraf@suug.ch
In-Reply-To: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 19 Sep 2006 00:08:00 +0900 (JST)

>     [XFRM]: Do not add a state whose SPI is zero to the SPI hash.
>     
>     SPI=0 is used for acquired IPsec SA and MIPv6 RO state.
>     Such state should not be added to the SPI hash
>     because we do not care about it on deleting path.
>     
>     Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thank you.

But the rest of these patches need more thought about these header
file issues.

>     [NET]: Move netlink interface bits to linux/if_link.h.
>     
>     Moving netlink interface bits to linux/if.h is rather troublesome for
>     applications including both linux/if.h (which was changed to be included
>     from linux/rtnetlink.h automatically) and net/if.h.
>     
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

If it is illegal for user to include kernel's linux/if.h (by any
means) if he uses net/if.h from userland headers, then he should
also avoid including the kernel's rtnetlink.h header too.

I understand the issue, in that net/if.h defines macros that
linux/if.h defines as well so there are conflicts (even though
in the end the same exact values are used).

What I see happening is that the troublesome interfaces move from
linux/if.h to a new file named linux/if_addr.h, then this gets
included again to linux/rtnetlink.h but only for userspace with
some messy ifdefs.

These kinds of things don't go away, they stay around forever once
you decide to support them.

Actually, what I'm going to do is apply:

[NET]: Move netlink interface bits to linux/if_link.h.
[NET] KBUILD: Add missing entries for new net headers.

And leave the rest for now.

Thank you.
