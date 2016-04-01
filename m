From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 4/4] samples/bpf: Enable powerpc support
Date: Fri, 1 Apr 2016 10:58:34 -0700
Message-ID: <56FEB6CA.6060607@fb.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <28a3811d03f6e8f7dca989a4ade536bf9aa8c7ce.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD63F4.2010500@fb.com> <20160401144131.GG17907@naverao1-tp.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>, "David S . Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:5295 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbcDAR6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 13:58:52 -0400
In-Reply-To: <20160401144131.GG17907@naverao1-tp.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/16 7:41 AM, Naveen N. Rao wrote:
> On 2016/03/31 10:52AM, Alexei Starovoitov wrote:
>> On 3/31/16 4:25 AM, Naveen N. Rao wrote:
>> ...
>>> +
>>> +#ifdef __powerpc__
>>> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)		{ (ip) = (ctx)->link; }
>>> +#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)	BPF_KPROBE_READ_RET_IP(ip, ctx)
>>> +#else
>>> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)						\
>>> +		bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx))
>>> +#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)					\
>>> +		bpf_probe_read(&(ip), sizeof(ip),				\
>>> +				(void *)(PT_REGS_FP(ctx) + sizeof(ip)))
>>
>> makes sense, but please use ({ }) gcc extension instead of {} and
>> open call to make sure that macro body is scoped.
>
> To be sure I understand this right, do you mean something like this?
>
> +
> +#ifdef __powerpc__
> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)                ({ (ip) = (ctx)->link; })
> +#define BPF_KRETPROBE_READ_RET_IP              BPF_KPROBE_READ_RET_IP
> +#else
> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)                ({                              \
> +               bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx)); })
> +#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)     ({                              \
> +               bpf_probe_read(&(ip), sizeof(ip),                               \
> +                               (void *)(PT_REGS_FP(ctx) + sizeof(ip))); })
> +#endif

yes. Thanks!
