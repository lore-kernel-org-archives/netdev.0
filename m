From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 12:15:06 +0200
Message-ID: <20150805101506.GY18673@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56931 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbHEKPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 06:15:18 -0400
Content-Disposition: inline
In-Reply-To: <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2015 at 12:04:25PM +0200, Peter Zijlstra wrote:
> On Tue, Aug 04, 2015 at 08:58:15AM +0000, Kaixu Xia wrote:

> > +	    event->ctx->task != current)

Strictly speaking we should hold rcu_read_lock around dereferencing
event->ctx (or have IRQs disabled -- although I know Paul doesn't like
us relying on that).
