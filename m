From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports for
	bridging device
Date: Mon, 23 Mar 2009 15:59:24 +0800
Message-ID: <2a27d3730903230059s5f6aa886k30515bd6429a1e71@mail.gmail.com>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: davem@davemloft.net, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:5910 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756979AbZCWH70 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 03:59:26 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2705130wff.4
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 00:59:24 -0700 (PDT)
In-Reply-To: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 5:04 PM, Li Yang <leoli@freescale.com> wrote:
> The bridging device used a constant hard_header_len. =C2=A0This will =
cause
> headroom shortage for ports with additional hardware header. =C2=A0Th=
e patch
> makes bridging device to use the maximum value of all ports.
>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> Fixes the following BUG when using bridging with gianfar driver:
>
> skb_under_panic: text:c0224b84 len:122 put:8 head:dfb81800 data:dfb81=
7fa tail:0xdfb81874 end:0xdfb818a0 dev:eth1
> ------------[ cut here ]------------
> Kernel BUG at c02d9444 [verbose debug info unavailable]
> Oops: Exception in kernel mode, sig: 5 [#1]
> Call Trace:
> [df2dbb20] [c02d9444] skb_under_panic+0x48/0x5c (unreliable)
> [df2dbb30] [c0224b94] gfar_start_xmit+0x384/0x400
> [df2dbb60] [c02e1c8c] dev_hard_start_xmit+0x258/0x2cc
> [df2dbba0] [c02f264c] __qdisc_run+0x5c/0x1f8
> [df2dbbd0] [c02e4bf4] dev_queue_xmit+0x264/0x2d0
> [df2dbbf0] [c036fdc8] br_dev_queue_push_xmit+0x90/0xf8
> [df2dbc00] [c036fcc8] br_flood+0xc8/0x120
> [df2dbc30] [c036ebe0] br_dev_xmit+0xbc/0xc0
> [df2dbc40] [c02e1c8c] dev_hard_start_xmit+0x258/0x2cc
> [df2dbc80] [c02e4c04] dev_queue_xmit+0x274/0x2d0
> [df2dbca0] [c02ebaa8] neigh_resolve_output+0xfc/0x25c
> ............

Any comment about this?  Is it possible to be included in 2.6.29?

- Leo
