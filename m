From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Thu, 1 Nov 2007 09:14:56 -0700
Message-ID: <20071101091456.26248ce0@freepuppy.rosehill>
References: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51032 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbXKAQRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 12:17:40 -0400
In-Reply-To: <4729A774.9030409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 01 Nov 2007 11:16:20 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> As done two years ago on IP route cache table (commit 
> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
> hash bucket for the huge TCP/DCCP hash tables.
> 
> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for litle 
> performance differences. (we hit a different cache line for the rwlock, but 
> then the bucket cache line have a better sharing factor among cpus, since we 
> dirty it less often)
> 
> Using a 'small' table of hashed rwlocks should be more than enough to provide 
> correct SMP concurrency between different buckets, without using too much 
> memory. Sizing of this table depends on NR_CPUS and various CONFIG settings.
> 
> This patch provides some locking abstraction that may ease a future work using 
>   a different model for TCP/DCCP table.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
>   include/net/inet_hashtables.h |   40 ++++++++++++++++++++++++++++----
>   net/dccp/proto.c              |   16 ++++++++++--
>   net/ipv4/inet_diag.c          |    9 ++++---
>   net/ipv4/inet_hashtables.c    |    7 +++--
>   net/ipv4/inet_timewait_sock.c |   13 +++++-----
>   net/ipv4/tcp.c                |   11 +++++++-
>   net/ipv4/tcp_ipv4.c           |   11 ++++----
>   net/ipv6/inet6_hashtables.c   |   19 ++++++++-------
>   8 files changed, 89 insertions(+), 37 deletions(-)
> 

Longterm is there any chance of using rcu for this? Seems like
it could be a big win.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
