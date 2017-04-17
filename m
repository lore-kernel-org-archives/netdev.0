From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 15:03:26 -0400 (EDT)
Message-ID: <20170417.150326.345314944044934203.davem@davemloft.net>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
        <58F50D13.3090001@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <58F50D13.3090001@iogearbox.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 17 Apr 2017 20:44:35 +0200

> On 04/17/2017 05:38 AM, David Miller wrote:
>> +/* Map BPF registers to SPARC registers */
>> +static const int bpf2sparc[] = {
>> + /* return value from in-kernel function, and exit value from eBPF */
>> +	[BPF_REG_0] = I5,
>> +
>> +	/* arguments from eBPF program to in-kernel function */
>> +	[BPF_REG_1] = I0,
>> +	[BPF_REG_2] = I1,
>> +	[BPF_REG_3] = I2,
>> +	[BPF_REG_4] = I3,
>> +	[BPF_REG_5] = I4,
>> +
>> + /* callee saved registers that in-kernel function will preserve */
>> +	[BPF_REG_6] = L0,
>> +	[BPF_REG_7] = L1,
>> +	[BPF_REG_8] = L2,
>> +	[BPF_REG_9] = L3,
>> +
>> +	/* read-only frame pointer to access stack */
>> +	[BPF_REG_FP] = FP,
> 
> On a quick initial glance, you also need to map BPF_REG_AX. If
> I understand the convention correctly, you could use L7 for that.
> 
> You can test for it through tools/testing/selftests/bpf/test_kmod.sh
> which exercises the test_bpf.ko under various sysctl combinations as
> part of the BPF selftest suite.

Oh I see, it's used for constant blinding.  I can use a global register
for that since it's only used as a temporary right?
