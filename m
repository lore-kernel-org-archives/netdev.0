From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Wed, 07 Apr 2010 13:47:37 +0300
Message-ID: <4BBC62C9.80802@cs.helsinki.fi>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>	 <alpine.DEB.2.00.1003250942080.2670@router.home>	 <1269570902.9614.92.camel@alexs-hp.sh.intel.com>	 <1270114166.2078.107.camel@ymzhang.sh.intel.com>	 <alpine.DEB.2.00.1004011050340.16531@router.home>	 <1270195589.2078.116.camel@ymzhang.sh.intel.com>	 <alpine.DEB.2.00.1004050853300.23149@router.home>	 <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>	 <4BBA8DF9.8010409@kernel.org>	 <1270542497.2078.123.camel@ymzhang.sh.intel.com>	 <alpine.DEB.2.00.1004061033330.18750@router.home>	 <alpine.DEB.2.00.1004061552500.19151@router.home>	 <1270591841.2091.170.camel@edumazet-laptop> <1270607668.2078.259.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36952 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab0DGKrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:47:40 -0400
In-Reply-To: <1270607668.2078.259.camel@ymzhang.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin kirjoitti:
> Kernel 2.6.34-rc3:
> # Samples: 13079611308 LLC-load-misses
> #
> # Overhead          Command                                                         Shared Object  Symbol
> # ........  ...............  ....................................................................  ......
> #
>     18.55%        hackbench  [kernel.kallsyms]                                                     [k] copy_user_generic_str
> ing
>     13.19%        hackbench  [kernel.kallsyms]                                                     [k] unix_stream_recvmsg
>     11.62%        hackbench  [kernel.kallsyms]                                                     [k] kfree
>      8.54%        hackbench  [kernel.kallsyms]                                                     [k] kmem_cache_free
>      7.88%        hackbench  [kernel.kallsyms]                                                     [k] __kmalloc_node_track_
> caller
>      6.54%        hackbench  [kernel.kallsyms]                                                     [k] kmem_cache_alloc_node
>      5.94%        hackbench  [kernel.kallsyms]                                                     [k] kfree_skb
>      3.48%        hackbench  [kernel.kallsyms]                                                     [k] __slab_free
>      2.15%        hackbench  [kernel.kallsyms]                                                     [k] _raw_spin_lock
>      1.83%        hackbench  [kernel.kallsyms]                                                     [k] schedule
>      1.82%        hackbench  [kernel.kallsyms]                                                     [k] get_partial_node
>      1.59%        hackbench  hackbench                                                             [.] receiver
>      1.37%        hackbench  libpthread-2.9.so                                                     [.] __read

Btw, you might want to try out "perf record -g" and "perf report 
--callchain fractal,5" to get a better view of where we're spending 
time. Perhaps you can spot the difference with that more easily.
