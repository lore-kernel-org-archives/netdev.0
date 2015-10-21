From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 13:33:17 +0200
Message-ID: <20151021113316.GM17308@twins.programming.kicks-ass.net>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: xiakaixu <xiakaixu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57512 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbJULda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 07:33:30 -0400
Content-Disposition: inline
In-Reply-To: <56276968.6070604@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 06:31:04PM +0800, xiakaixu wrote:

> The RFC patch set contains the necessary commit log [1].

That's of course the wrong place, this should be in the patch's
Changelog. It doesn't become less relevant.

> In some scenarios we don't want to output trace data when perf sampling
> in order to reduce overhead. For example, perf can be run as daemon to
> dump trace data when necessary, such as the system performance goes down.
> Just like the example given in the cover letter, we only receive the
> samples within sys_write() syscall.
> 
> The helper bpf_perf_event_control() in this patch set can control the
> data output process and get the samples we are most interested in.
> The cpu_function_call is probably too much to do from bpf program, so
> I choose current design that like 'soft_disable'.

So, IIRC, we already require eBPF perf events to be CPU-local, which
obviates the entire need for IPIs.

So calling pmu->stop() seems entirely possible (its even NMI safe).
This, however, does not explain if you need nesting, your patch seemed
to have a counter, which suggest you do.

In any case, you could add perf_event_{stop,start}_local() to mirror the
existing perf_event_read_local(), no? That would stop the entire thing
and reduce even more overhead than simply skipping the overflow handler.

> [1] https://lkml.org/lkml/2015/10/12/135

Blergh, vger should auto drop emails with lkml.org links in, that site
is getting ridiculously unreliable. (It did show the email after a
second try -- this time)

Proper links are of the form:

  http://lkml.kernel.org/r/$MSGID

Those have the bonus of actually including the msgid which helps with
finding the email in local archives/mailers.
