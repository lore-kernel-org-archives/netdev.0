From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Checksum offload and XDP
Date: Tue, 11 Apr 2017 15:00:48 -0400 (EDT)
Message-ID: <20170411.150048.966246483547817859.davem@davemloft.net>
References: <63f0f671-5b33-4895-355c-be6259b16341@solarflare.com>
        <58ED07C3.50308@iogearbox.net>
        <20170411113402.48614665@cakuba.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ecree@solarflare.com, tom@herbertland.com,
        netdev@vger.kernel.org, ast@kernel.org
To: kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752276AbdDKTAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 15:00:50 -0400
In-Reply-To: <20170411113402.48614665@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>
Date: Tue, 11 Apr 2017 11:34:25 -0700

> On Tue, 11 Apr 2017 18:43:47 +0200, Daniel Borkmann wrote:
>> cls_bpf has a couple of helpers like bpf_l3_csum_replace(), bpf_l4_csum_replace()
>> bpf_csum_diff(), bpf_csum_update(), where we (cilium at least) use checksum
>> diffs extensively. You can then also leave the option to the user to feed
>> pre-computed diffs from a map, etc, or, to just not care at all when not
>> necessary. Pushing this via return code seems a bit odd, perhaps a xdp->csum
>> member could be populated before calling into the program and the resulting
>> xdp->csum processed further upon exit.
> 
> +1 on exposing xdp->csum.  I think having the csum complete available
> in the eBPF program (rather than diff) may be useful for apps doing
> encap to a csumed tunnel (e.g. UDP).  If the header is pre-calculated
> in the map, having csum complete makes calculating the outer csum
> extremely easy, right?

The outer checksum is constant because when the inner checksum is
installed the inner frame checksums to zero.

I really want to see how people are actually changing fields in XDP
that requires special checksum facilities, that isn't already handled
using the csum helpers Daniel mentioned.
