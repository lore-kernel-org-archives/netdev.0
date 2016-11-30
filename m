From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Wed, 30 Nov 2016 09:57:56 +0100
Message-ID: <20161130085756.GD16856@pox.localdomain>
References: <cover.1480424542.git.tgraf@suug.ch>
 <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
 <20161130001504.GA28238@ast-mbp.thefacebook.com>
 <20161130064850.GB16856@pox.localdomain>
 <20161130070150.GA33397@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38753 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757334AbcK3I6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 03:58:00 -0500
Received: by mail-wm0-f45.google.com with SMTP id f82so212822335wmf.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 00:57:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161130070150.GA33397@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 at 11:01pm, Alexei Starovoitov wrote:
> On Wed, Nov 30, 2016 at 07:48:51AM +0100, Thomas Graf wrote:
> > Should we check in __bpf_redirect_common() whether mac_header <
> > nework_header then or add it to lwt-bpf conditional on
> > dev_is_mac_header_xmit()?
> 
> may be only extra 'if' in lwt-bpf is all we need?

Agreed, I will add a mac_header < network_header check to lwt-bpf if we
redirect to an l2 device.

> I'm still missing what will happen if we 'forget' to do
> bpf_skb_push() inside the lwt-bpf program, but still do redirect
> in lwt_xmit stage to l2 netdev...

The same as for a AF_PACKET socket not providing an actual L2 header.
I will add a test case to cover this scenario as well.
