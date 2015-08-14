From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 V2] ipv4: off-by-one in continuation handling in
 /proc/net/route
Date: Thu, 13 Aug 2015 21:16:41 -0700 (PDT)
Message-ID: <20150813.211641.2238542515138447940.davem@davemloft.net>
References: <1439495341-12095-1-git-send-email-apw@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.duyck@gmail.com
To: apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439495341-12095-1-git-send-email-apw@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Whitcroft <apw@canonical.com>
Date: Thu, 13 Aug 2015 20:49:01 +0100

> When generating /proc/net/route we emit a header followed by a line for
> each route.  When a short read is performed we will restart this process
> based on the open file descriptor.  When calculating the start point we
> fail to take into account that the 0th entry is the header.  This leads
> us to skip the first entry when doing a continuation read.
> 
> This can be easily seen with the comparison below:
> 
>   while read l; do echo "$l"; done </proc/net/route >A
>   cat /proc/net/route >B
>   diff -bu A B | grep '^[+-]'
> 
> On my example machine I have approximatly 10KB of route output.  There we
> see the very first non-title element is lost in the while read case,
> and an entry around the 8K mark in the cat case:
> 
>   +wlan0 00000000 02021EAC 0003 0 0 400 00000000 0 0 0
>   -tun1  00C0AC0A 00000000 0001 0 0 950 00C0FFFF 0 0 0
> 
> Fix up the off-by-one when reaquiring position on continuation.
> 
> Fixes: 8be33e955cb9 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")                                   
> BugLink: http://bugs.launchpad.net/bugs/1483440
> Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> Signed-off-by: Andy Whitcroft <apw@canonical.com>

Applied and queued up for -stable, thanks.
