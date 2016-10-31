From: Thomas Graf <tgraf@suug.ch>
Subject: Re: XDP question - how much can BPF change in xdp_buff?
Date: Mon, 31 Oct 2016 22:18:41 +0100
Message-ID: <20161031211841.GG32374@pox.localdomain>
References: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
 <20161031.145734.1243544464767231445.davem@davemloft.net>
 <581799F9.6060704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Yuval.Mintz@cavium.com,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35540 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947010AbcJaVSo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 17:18:44 -0400
Received: by mail-wm0-f48.google.com with SMTP id a197so44475009wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 14:18:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <581799F9.6060704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 at 12:22pm, John Fastabend wrote:
> On 16-10-31 11:57 AM, David Miller wrote:
> > My understanding is that the eBPF program would be responsible
> > for updating the checksum if it mangles the packet in such a
> > way that such a fixup would be required.
> > 
> 
> For XDP we will probably need to add support for at minimum the
> following helpers,
> 
> 	bpf_l3_csum_replace
> 	bpf_l4_csum_replace
	csum_diff

We definitely want some visibility feature that can be enabled for
troubleshooting and debugging which verifies the checksum in SW
after the bpf program is done. Otherwise, if a XDP BPF program
miscalculates the checksum, there is no way to figure it out whether
the checksum is off without attaching another system to capture.

Speaking from experience, getting the checksum right is one of the
time sinks when developing more complex BPF programs.
