From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf helpers to use skb->mac_header
 relative offsets
Date: Thu, 16 Apr 2015 14:09:21 -0400 (EDT)
Message-ID: <20150416.140921.1393061800863505093.davem@davemloft.net>
References: <1429127745-5960-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, daniel@iogearbox.net, tgraf@suug.ch,
	jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565AbbDPSJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:09:23 -0400
In-Reply-To: <1429127745-5960-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 15 Apr 2015 12:55:45 -0700

> For the short-term solution, lets fix bpf helper functions to use
> skb->mac_header relative offsets instead of skb->data in order to
> get the same eBPF programs with cls_bpf and act_bpf work on ingress
> and egress qdisc path. We need to ensure that mac_header is set
> before calling into programs. This is effectively the first option
> from below referenced discussion.
> 
> More long term solution for LD_ABS|LD_IND instructions will be more
> intrusive but also more beneficial than this, and implemented later
> as it's too risky at this point in time.
> 
> I.e., we plan to look into the option of moving skb_pull() out of
> eth_type_trans() and into netif_receive_skb() as has been suggested
> as second option. Meanwhile, this solution ensures ingress can be
> used with eBPF, too, and that we won't run into ABI troubles later.
> For dealing with negative offsets inside eBPF helper functions,
> we've implemented bpf_skb_clone_unwritable() to test for unwriteable
> headers.
> 
> Reference: http://thread.gmane.org/gmane.linux.network/359129/focus=359694
> Fixes: 608cd71a9c7c ("tc: bpf: generalize pedit action")
> Fixes: 91bc4822c3d6 ("tc: bpf: add checksum helpers")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
