From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLAB vs. SLUB tbench regression (Was: [tbench regression fixes]: digging out smelly deadmen.)
Date: Fri, 31 Oct 2008 17:08:32 +0200
Message-ID: <84144f020810310808p9d6ecf9k6f10a671c21bf0da@mail.gmail.com>
References: <84144f020810310728j1f3b8a99se428ec55b0c165b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>,
	"Ingo Molnar" <mingo@elte.hu>,
	"David Miller" <davem@davemloft.net>,
	"Christoph Lameter" <cl@linux-foundation.org>,
	"Matthew Wilcox" <matthew@wil.cx>,
	"Eric Dumazet" <dada1@cosmosbay.com>,
	"Nick Piggin" <nickpiggin@yahoo.com.au>
To: "Evgeniy Polyakov" <s0mbre@tservice.net.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:54238 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbYJaPId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 11:08:33 -0400
In-Reply-To: <84144f020810310728j1f3b8a99se428ec55b0c165b5@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 4:28 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> Hi Evgeniy,
>
> On Fri, Oct 10, 2008 at 1:17 AM, Evgeniy Polyakov
> <s0mbre@tservice.net.ru> wrote:
>> It was reported recently that tbench has a long history of regressions,
>> starting at least from 2.6.23 kernel. I verified that in my test
>> environment tbench 'lost' more than 100 MB/s from 470 down to 355
>> between at least 2.6.24 and 2.6.27. 2.6.26-2.6.27 performance regression
>> in my machines is rougly corresponds to 375 down to 355 MB/s.
>
> As you've already pointed out in private and in your blog, some part
> of the tbench regression comes from SLUB vs. SLAB as well. Looks like
> I can reproduce the regression locally as well:
>
>  [ 8 clients and tbench_srv on the same machine on 2-way x86-64 ]
>
>                  min      max      avg      sd
>  2.6.28-rc2-slab 234.57   244.88   242.68   0.71
>  2.6.28-rc2-slub 227.44   240.90   239.08   0.78

Christoph asked me to throw in the prefetch patch from Eric Dumazet.
Unfortunately, it doesn't seem to make much of a difference:

[ 2-way x86-64 with 8 clients and tbench_srv on the same machine ]

                           min      max      avg      sd
  2.6.28-rc2-slab          234.57   244.88   242.68   0.71
  2.6.28-rc2-slub          227.44   240.90   239.08   0.78
  2.6.28-rc2-slub+prefetch 237.42   244.32   239.78   0.92
