From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 1/3] bpf: fix off by one for range markings with
 L{T,E} patterns
Date: Sat, 21 Oct 2017 09:39:35 -0700
Message-ID: <0a607e55-3ccb-eab4-f11b-8ef7c9b55c49@gmail.com>
References: <cover.1508545543.git.daniel@iogearbox.net>
 <3df9cce096b139eb0efb3b0c7bf9fcc5c5dc6629.1508545543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:44423 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbdJUQj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 12:39:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so8801912pga.1
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 09:39:59 -0700 (PDT)
In-Reply-To: <3df9cce096b139eb0efb3b0c7bf9fcc5c5dc6629.1508545543.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 05:34 PM, Daniel Borkmann wrote:
> During review I noticed that the current logic for direct packet
> access marking in check_cond_jmp_op() has an off by one for the
> upper right range border when marking in find_good_pkt_pointers()
> with BPF_JLT and BPF_JLE. It's not really harmful given access
> up to pkt_end is always safe, but we should nevertheless correct
> the range marking before it becomes ABI. If pkt_data' denotes a
> pkt_data derived pointer (pkt_data + X), then for pkt_data' < pkt_end
> in the true branch as well as for pkt_end <= pkt_data' in the false
> branch we mark the range with X although it should really be X - 1
> in these cases. For example, X could be pkt_end - pkt_data, then
> when testing for pkt_data' < pkt_end the verifier simulation cannot
> deduce that a byte load of pkt_data' - 1 would succeed in this
> branch.
> 
> Fixes: b4e432f1000a ("bpf: enable BPF_J{LT, LE, SLT, SLE} opcodes in verifier")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---

Acked-by: John Fastabend <john.fastabend@gmail.com>
