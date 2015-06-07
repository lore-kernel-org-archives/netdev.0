From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] bpf: make programs see skb->data == L2
 for ingress and egress
Date: Sun, 07 Jun 2015 02:01:53 -0700 (PDT)
Message-ID: <20150607.020153.2078872410885973154.davem@davemloft.net>
References: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, jhs@mojatatu.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbbFGJBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 05:01:54 -0400
In-Reply-To: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  4 Jun 2015 10:11:53 -0700

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
>        w/o JIT   w/JIT
> before  20.5     23.6 Mpps
> after   21.8     26.6 Mpps
> 
> Old programs with BPF_LL_OFF will still work as-is.
> 
> We can now undo most of the earlier workaround commit:
> a166151cbe33 ("bpf: fix bpf helpers to use skb->mac_header relative offsets")
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
