From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6] xt_hashlimit: RCU conversion
Date: Thu, 01 Apr 2010 13:03:29 +0200
Message-ID: <4BB47D81.3060400@trash.net>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>	 <1269509574.3626.9.camel@edumazet-laptop>  <4BAB3C8B.3030104@trash.net>	 <1269514928.3626.13.camel@edumazet-laptop> <1270038210.2103.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270038210.2103.23.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> xt_hashlimit uses a central lock per hash table and suffers from
> contention on some workloads. (Multiqueue NIC or if RPS is enabled)
> 
> After RCU conversion, central lock is only used when a writer wants to
> add or delete an entry.
> 
> For 'readers', updating an existing entry, they use an individual lock
> per entry.

Looks good to me, thanks Eric.

> -/* allocate dsthash_ent, initialize dst, put in htable and lock it */
> -static struct dsthash_ent *
> -dsthash_alloc_init(struct xt_hashlimit_htable *ht,
> -		   const struct dsthash_dst *dst)

Is there a reason for moving this function downwards in the file?
That unnecessarily increases the diff and makes the patch harder to
review. For review purposes I moved it back up, resulting in 42
lines less diff.
