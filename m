From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Thu, 22 Oct 2015 08:38:02 -0700
Message-ID: <562902DA.7010908@plumgrid.com>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <20151022135930.GN3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36524 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050AbbJVPiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 11:38:03 -0400
Received: by pacfv9 with SMTP id fv9so93892488pac.3
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 08:38:02 -0700 (PDT)
In-Reply-To: <20151022135930.GN3604@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/15 6:59 AM, Peter Zijlstra wrote:
>> +	if (unlikely(event->oncpu != smp_processor_id()))
>> >+		return -EOPNOTSUPP;
>> >+
>> >+	perf_sample_data_init(&sample_data, 0, 0);
>> >+	sample_data.raw = &raw;
>> >+	perf_event_output(event, &sample_data, regs);
>> >+	return 0;
>> >+}
> Note that this function also very much requires event to be local.

correct. that's why there is a dynamic check above to prevent buggy
programs causing issues.
