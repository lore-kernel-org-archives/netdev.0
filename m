From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Tue, 12 Jan 2016 11:56:41 -0800
Message-ID: <20160112195641.GA34601@ast-mbp.thefacebook.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
 <20160111180913.GA25950@ast-mbp.thefacebook.com>
 <56949028.2070208@huawei.com>
 <20160112061145.GA31444@ast-mbp.thefacebook.com>
 <5694F347.5010700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, acme@kernel.org,
	linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Yunlong Song <yunlong.song@huawei.com>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34729 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbcALT4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:56:44 -0500
Content-Disposition: inline
In-Reply-To: <5694F347.5010700@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 08:36:23PM +0800, Wangnan (F) wrote:
> >hmm, in this kernel patch I see that you're adding 8 bytes for
> >every record via this extra TAILSISZE flag and in perf you're
> >walking the ring buffer backwards by reading this 8 byte
> >sizes, comparing header sizes and so on until reaching beginning,
> >where you start dumping it as normal.
> >So for this 'signal to perf' approach to work the ring buffer
> >will contain tailsizes everywhere just so that user space can
> >find the beginning. That's not very pretty. imo if kernel
> >can do header read to adjust data_tail it would make user
> >space side clean. May be there are other solutions.
> >Adding tailsize seems like brute force hack.
> >There must be some nicer way.
> Hi Peter,
> 
>  What's your opinion? Should we reconsider moving size field from header the
> end?
> Or moving whole header to the end of a record?

I think moving the whole header under new TAILHEADER flag is
actually very good idea. The ring buffer will be fully utilized
and no extra bytes necessary. User space would need to parse it
backwards, but for this use case it fits well.
