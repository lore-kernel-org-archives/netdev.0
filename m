From: David Miller <davem@davemloft.net>
Subject: Re: XDP question - how much can BPF change in xdp_buff?
Date: Mon, 31 Oct 2016 14:57:34 -0400 (EDT)
Message-ID: <20161031.145734.1243544464767231445.davem@davemloft.net>
References: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945655AbcJaS5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:57:36 -0400
In-Reply-To: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 31 Oct 2016 18:31:30 +0000

> So I've [finally] started looking into implementing XDP
> for qede, and there's one thing I feel like I'm missing in
> regard to XDP_TX - what's the guarantee/requirement
> that the bpf program isn't going to transmute some fields
> of the rx packet in a way that would prevent the forwarding?
> 
> E.g., can a BPF change the TCP payload of an incoming packet
> without correcting its TCP checksum, and then expect the
> driver to transmit it [via XDP_TX]? If not, how is this enforced [if at all]?
> 
> [Looked at samples/bpf/xdp2_kern.c which manipulates the
> UDP header; so I'm not certain what prevents it from doing
> the same when checksum modifications would be required]

My understanding is that the eBPF program would be responsible
for updating the checksum if it mangles the packet in such a
way that such a fixup would be required.
