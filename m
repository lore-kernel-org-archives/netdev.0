From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: RFC: Checksum offload and XDP
Date: Tue, 11 Apr 2017 11:34:25 -0700
Message-ID: <20170411113402.48614665@cakuba.lan>
References: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
        <63f0f671-5b33-4895-355c-be6259b16341@solarflare.com>
        <58ED07C3.50308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:30182 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753174AbdDKSen (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 14:34:43 -0400
In-Reply-To: <58ED07C3.50308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Apr 2017 18:43:47 +0200, Daniel Borkmann wrote:
> cls_bpf has a couple of helpers like bpf_l3_csum_replace(), bpf_l4_csum_replace()
> bpf_csum_diff(), bpf_csum_update(), where we (cilium at least) use checksum
> diffs extensively. You can then also leave the option to the user to feed
> pre-computed diffs from a map, etc, or, to just not care at all when not
> necessary. Pushing this via return code seems a bit odd, perhaps a xdp->csum
> member could be populated before calling into the program and the resulting
> xdp->csum processed further upon exit.

+1 on exposing xdp->csum.  I think having the csum complete available
in the eBPF program (rather than diff) may be useful for apps doing
encap to a csumed tunnel (e.g. UDP).  If the header is pre-calculated
in the map, having csum complete makes calculating the outer csum
extremely easy, right?
