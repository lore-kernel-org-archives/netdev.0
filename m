From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, trace: use READ_ONCE for retrieving file ptr
Date: Tue, 07 Jun 2016 14:48:46 -0700 (PDT)
Message-ID: <20160607.144846.1662240162265441902.davem@davemloft.net>
References: <5aa8512414e4f9f19734e59665f0fe893a109be2.1465065428.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, xiakaixu@huawei.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbcFGVss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 17:48:48 -0400
In-Reply-To: <5aa8512414e4f9f19734e59665f0fe893a109be2.1465065428.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat,  4 Jun 2016 20:50:59 +0200

> In bpf_perf_event_read() and bpf_perf_event_output(), we must use
> READ_ONCE() for fetching the struct file pointer, which could get
> updated concurrently, so we must prevent the compiler from potential
> refetching.
> 
> We already do this with tail calls for fetching the related bpf_prog,
> but not so on stored perf events. Semantics for both are the same
> with regards to updates.
> 
> Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks.
