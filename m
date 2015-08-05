From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read() that
 get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 09:08:32 -0700
Message-ID: <55C23500.1000207@plumgrid.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
 <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>,
	Kaixu Xia <xiakaixu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33705 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbbHEQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 12:08:34 -0400
Received: by pdrh1 with SMTP id h1so2429354pdr.0
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 09:08:33 -0700 (PDT)
In-Reply-To: <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/5/15 6:53 AM, Peter Zijlstra wrote:
> +	/*
> +	 * If the event is currently on this CPU, its either a per-task event,
> +	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
> +	 * oncpu == -1).
> +	 */
> +	if (event->oncpu == smp_processor_id())
> +		event->pmu->read(event);
> +
> +	val = local64_read(&event->count);
> +	local_irq_restore(flags);
> +

nice! cleaner and faster.
so raw_spin_lock(&ctx->lock) is not needed, because
update_*(event) methods are not called, right?
