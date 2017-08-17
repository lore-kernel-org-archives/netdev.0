From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 07/10] bpf: add access to sock fields and pkt
 data from sk_skb programs
Date: Thu, 17 Aug 2017 14:40:28 +0200
Message-ID: <59958EBC.6070502@iogearbox.net>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810> <20170816053309.15445.97681.stgit@john-Precision-Tower-5810> <f6bdacf6-7a8c-226f-5a22-f14bebac356b@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, tom@herbertland.com
To: Alexei Starovoitov <ast@fb.com>,
        John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37431 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdHQMkf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 08:40:35 -0400
In-Reply-To: <f6bdacf6-7a8c-226f-5a22-f14bebac356b@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 07:42 AM, Alexei Starovoitov wrote:
> On 8/15/17 10:33 PM, John Fastabend wrote:
>> +static int sk_skb_prologue(struct bpf_insn *insn_buf, bool direct_write,
>> +               const struct bpf_prog *prog)
>> +{
>> +    struct bpf_insn *insn = insn_buf;
>> +
>> +    if (!direct_write)
>> +        return 0;
>> +
>> +    /* if (!skb->cloned)
>> +     *       goto start;
>> +     *
>> +     * (Fast-path, otherwise approximation that we might be
>> +     *  a clone, do the rest in helper.)
>> +     */
>
> iirc we're doing something similar in other prologue generator?
> can be consolidated?

Jup, with tc. I'll fix this one so the two can be consolidated.

Cheers,
Daniel
