From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/2] bpf: make programs see skb->data == L2
 for ingress and egress
Date: Fri, 05 Jun 2015 06:03:15 -0400
Message-ID: <557173E3.5020807@mojatatu.com>
References: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:32896 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123AbbFEKDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 06:03:23 -0400
Received: by iebgx4 with SMTP id gx4so54374133ieb.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 03:03:23 -0700 (PDT)
In-Reply-To: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/15 13:11, Alexei Starovoitov wrote:
> eBPF programs attached to ingress and egress qdiscs see inconsistent skb->data.
> For ingress L2 header is already pulled, whereas for egress it's present.
> This is known to program writers which are currently forced to use
> BPF_LL_OFF workaround.
> Since programs don't change skb internal pointers it is safe to do
> pull/push right around invocation of the program and earlier taps and
> later pt->func() will not be affected.
> Multiple taps via packet_rcv(), tpacket_rcv() are doing the same trick
> around run_filter/BPF_PROG_RUN even if skb_shared.
>
> This fix finally allows programs to use optimized LD_ABS/IND instructions
> without BPF_LL_OFF for higher performance.
> tc ingress + cls_bpf + samples/bpf/tcbpf1_kern.o
>         w/o JIT   w/JIT
> before  20.5     23.6 Mpps
> after   21.8     26.6 Mpps
>
> Old programs with BPF_LL_OFF will still work as-is.
>
> We can now undo most of the earlier workaround commit:
> a166151cbe33 ("bpf: fix bpf helpers to use skb->mac_header relative offsets")
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
