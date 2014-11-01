From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Sat, 01 Nov 2014 19:31:37 +0100
Message-ID: <54552709.7000409@redhat.com>
References: <CAOJe8K31iB9+7c1BnS=6DdriU08WUisM7sYgj8nOBo4Fg=XUBg@mail.gmail.com> <20141101.133957.1365371956675094081.davem@davemloft.net> <CAOJe8K2FzuPTZ5pch8_UK7X==+=k8RKLnfz0mZb2hca19aU4pg@mail.gmail.com> <20141101.140035.13626854970331774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	mpe@ellerman.id.au, matt@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759390AbaKASbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Nov 2014 14:31:53 -0400
In-Reply-To: <20141101.140035.13626854970331774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2014 07:00 PM, David Miller wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Sat, 1 Nov 2014 21:49:27 +0400
>
>> David, you need a feedback from other guys to apply this patch, right?
>>
>> Alexei wanted some output before/after the patch.
>> Michael Ellerman wanted the explanation what a BPF_ANC | SKF_AD_PKTTYPE means.

The BPF_ANC | SKF_AD_PKTTYPE case means that this is an ancillary
operation aka BPF extension which loads the value of skb->pkt_type
into the accumulator.

A similar transformation, that is, from BPF into eBPF insns can be
found in convert_bpf_extensions() in the SKF_AD_PKTTYPE case, or
commit 709f6c58d4dc ("sparc: bpf_jit: add SKF_AD_PKTTYPE support
to JIT") that recently enabled the same in sparc.

>> So I'm waiting  the ack/nack from them...
>
> I don't really think performance metrics are necessary just for adding
> SKF_AD_PKTTYPE support, that's sort of an over the top requirement
> if you ask me.

Right, lib/test_bpf.c actually brings the quoted output w/ numbers
for free. I think the important point was that the 'After:' case
with ``echo 1 > /proc/sys/net/core/bpf_jit_enable'' runs through for
that test case, which has been shown here.

> It's pretty obvious that we should support as many operations as
> possible to each JIT, because all of program has to do is use that
> unsupported opcode and then we have none of that program being JIT'd.
