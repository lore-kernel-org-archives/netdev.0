From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Mon, 26 Oct 2015 21:50:57 -0700 (PDT)
Message-ID: <20151026.215057.1299451307191406499.davem@davemloft.net>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, a.p.zijlstra@chello.nl, wangnan0@huawei.com,
	hekuang@huawei.com, xiakaixu@huawei.com, daniel@iogearbox.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbJ0EeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:34:21 -0400
In-Reply-To: <1445559014-4667-1-git-send-email-ast@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 22 Oct 2015 17:10:14 -0700

> Fix safety checks for bpf_perf_event_read():
> - only non-inherited events can be added to perf_event_array map
>   (do this check statically at map insertion time)
> - dynamically check that event is local and !pmu->count
> Otherwise buggy bpf program can cause kernel splat.
> 
> Also fix error path after perf_event_attrs()
> and remove redundant 'extern'.
> 
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, although my tendancy is to agree with the sentiment that you must
respect the entire universe of valid 64-bit counter values.  I do not buy
the arguments about values overlapping error codes being unlikely or not
worth worrying about.

Just FYI...
