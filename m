From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 13:38:24 -0700
Message-ID: <1369255104.2143.108.camel@joe-AO722>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <1369246816.2143.84.camel@joe-AO722>
	 <1369250772.3301.349.camel@edumazet-glaptop>
	 <1369252624.2143.103.camel@joe-AO722>
	 <1369253761.3301.355.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41447 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756945Ab3EVUiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 16:38:25 -0400
In-Reply-To: <1369253761.3301.355.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 13:16 -0700, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 12:57 -0700, Joe Perches wrote:
> > It might also be nice to mark it if ever more than a u16
> > brace/flock/coven/cluster worth of cpus become feasible
> > as it seems int is used almost everywhere else.
> 
> It seems Linus hates cpu_t or whatever_t

Go figure.

> Thats why we have u16 everywhere to code cpu numbers, and why we use
> "unsigned long" for jiffies.

u16 for cpu is hardly used at all.

$ git grep -E "^\s*\w+\s+cpu\s*;" | cut -f2- -d":" | \
  sed -r -e 's/^\s+//g' -e 's/\s+/ /g' -e 's/;.*//' | \
  sort | uniq -c | sort -rn
    569 int cpu
     29 return cpu
     28 __u32 cpu
     14 u32 cpu
      7 unsigned cpu
      5 u16 cpu
      4 cpuid_t cpu
      3 uint32_t cpu
      2 __u8 cpu
      2 u64 cpu
      2 s32 cpu
      2 long cpu
      1 u8 cpu
      1 __u16 cpu
      1 struct cpu
      1 short cpu
      1 __le32 cpu
      1 geo_cpu_t cpu

> So far, I believe linux supports at most 4096 cpus.

I believe that as well.
