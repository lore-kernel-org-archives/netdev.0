From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sparc64: Add eBPF JIT.
Date: Sat, 22 Apr 2017 14:27:22 -0400 (EDT)
Message-ID: <20170422.142722.2115566524446267818.davem@davemloft.net>
References: <20170421.201711.317784995765325131.davem@davemloft.net>
        <20170422153233.GA47144@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170422153233.GA47144@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Sat, 22 Apr 2017 08:32:35 -0700

> On Fri, Apr 21, 2017 at 08:17:11PM -0700, David Miller wrote:
>> 
>> This is an eBPF JIT for sparc64.  All major features are supported.
>> 
>> All tests under tools/testing/selftests/bpf/ pass.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> ...
>> +	/* tail call */
>> +	case BPF_JMP | BPF_CALL |BPF_X:
>> +		emit_tail_call(ctx);
>> +
> 
> I think 'break;' is missing here.

Good catch, I'll fix that.

> When tail_call's target program is null the current program should
> continue instead of aborting.
> Like in our current ddos+lb setup the program looks like:
>  bpf_tail_call(ctx, &prog_array, 1);
>  bpf_tail_call(ctx, &prog_array, 2);
>  bpf_tail_call(ctx, &prog_array, 3);
>  return XDP_DROP;
> 
> this way it will jump into the program that is installed in slot 1.
> If it's empty, it will try slot 2...
> If no programs installed it will drop the packet.

Yes, with the break; fixed above that's what the sparc64 JIT will
end up doing.  If any of the tests don't pass in emit_tail_call()
we branch to the end of the emit_tail_call() sequence.

Thanks.
