From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 07/10] bpf: add access to sock fields and pkt
 data from sk_skb programs
Date: Wed, 16 Aug 2017 22:42:12 -0700
Message-ID: <f6bdacf6-7a8c-226f-5a22-f14bebac356b@fb.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
 <20170816053309.15445.97681.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <tom@herbertland.com>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43886 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750903AbdHQFmi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 01:42:38 -0400
In-Reply-To: <20170816053309.15445.97681.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/17 10:33 PM, John Fastabend wrote:
> +static int sk_skb_prologue(struct bpf_insn *insn_buf, bool direct_write,
> +			   const struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	if (!direct_write)
> +		return 0;
> +
> +	/* if (!skb->cloned)
> +	 *       goto start;
> +	 *
> +	 * (Fast-path, otherwise approximation that we might be
> +	 *  a clone, do the rest in helper.)
> +	 */

iirc we're doing something similar in other prologue generator?
can be consolidated?
