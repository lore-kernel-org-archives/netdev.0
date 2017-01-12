From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] bpf: allow b/h/w/dw access for bpf's cb
 in ctx
Date: Thu, 12 Jan 2017 11:53:10 +0100
Message-ID: <58776016.1050303@iogearbox.net>
References: <cover.1484182858.git.daniel@iogearbox.net> <fff467f83e48c6c15053a7637893bf247c9be102.1484182858.git.daniel@iogearbox.net> <bb078a63-6bcc-22f8-c98e-8445f66678c9@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Quentin Monnet <quentin.monnet@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37790 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750804AbdALLUh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 06:20:37 -0500
In-Reply-To: <bb078a63-6bcc-22f8-c98e-8445f66678c9@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:25 AM, Quentin Monnet wrote:
> 2017-01-12 (02:21 +0100) ~ Daniel Borkmann <daniel@iogearbox.net>
[...]
>> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
>> index 9bb4534..f664bed 100644
>> --- a/tools/testing/selftests/bpf/test_verifier.c
>> +++ b/tools/testing/selftests/bpf/test_verifier.c
>> @@ -859,15 +859,451 @@ struct test_val {
>
> [...]
>
>> +	{
>> +		"check cb access: doulbe, oob 5",
>> +		.insns = {
>> +			BPF_MOV64_IMM(BPF_REG_0, 0),
>> +			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
>> +				    offsetof(struct __sk_buff, cb[4]) + 8),
>> +			BPF_EXIT_INSN(),
>> +		},
>> +		.errstr = "invalid bpf_context access",
>> +		.result = REJECT,
>> +	},
>
> Nitpicking: typo ("doulbe").

Thanks for spotting, I've sent out a v2.
