From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next v3] net: use a per task frag allocator
Date: Mon, 24 Sep 2012 11:34:47 -0700
Message-ID: <CAGK4HS9CFwaiR56tym6=FkhrDBwK62Kvm4qw62BWqUXAu3XbbQ@mail.gmail.com>
References: <1348073761.26523.1095.camel@edumazet-glaptop>
	<20120920.174827.1245530945282009606.davem@davemloft.net>
	<1348239433.2669.522.camel@edumazet-glaptop>
	<CAGK4HS98RG78Auvaai3Ny6zz5c_hccO-ShD3GuT=moRRm4+RUA@mail.gmail.com>
	<1348261871.2669.962.camel@edumazet-glaptop>
	<1348477482.26828.235.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49901 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757598Ab2IXSes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 14:34:48 -0400
Received: by obbuo13 with SMTP id uo13so4984813obb.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 11:34:47 -0700 (PDT)
In-Reply-To: <1348477482.26828.235.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Successfully tested on various ethernet devices.
> (ixgbe, igb, bnx2x, tg3, mellanox mlx4)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> v3: net/sched/em_meta.c bit pointed out by Vijay
> v2: uses existing page_frag structure to hold page/offset/size
>     convert linear_to_page()/__ip_append_data()/ip6_append_data()
>     remove @page and @off fields from struct inet_cork
>     move the destructor from tcp_v4_destroy_sock() to sk_common_release

With netperf (64KB send buffer) and with e1000e driver, I get 13%
improvement with v3 of this patch.
When I run netserver and netperf on separate cpus with taskset, I get
7% improvement.

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>


FYI, checkpatch complained about this patch with 4 lines over 80
characters (which probably be ignored I think) and one
trailing space error.

ERROR: trailing whitespace
#443: FILE: net/ipv4/raw.c:139:
+^Ipr_err("icmp_filter skb_transport_offset %d data-head %ld len %d/%d\n", $


Vijay
