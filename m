From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 2/2] pktgen: introduce xmit_mode
 '<start_xmit|netif_receive>'
Date: Fri, 08 May 2015 08:57:01 -0700
Message-ID: <1431100621.22756.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150507143329.8534.49710.stgit@ivy>
	 <20150507143500.8534.4435.stgit@ivy> <554B9293.2070702@plumgrid.com>
	 <554B9CDE.1050703@iogearbox.net> <20150508173900.3fcf78de@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38806 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbEHP5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 11:57:03 -0400
Received: by igbhj9 with SMTP id hj9so24958673igb.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 08:57:03 -0700 (PDT)
In-Reply-To: <20150508173900.3fcf78de@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-08 at 17:39 +0200, Jesper Dangaard Brouer wrote:

> The funny thing now is that scaling does not "happen" as we stall on:
>    atomic_long_inc(&skb->dev->rx_dropped);

Note we already have percpu device refcnt.

We could extend this to contain a per cpu rx_dropped, but I guess only
these tests hit this path, so I simply used one atomic_long_t here.

I guess an ingress action can do better, by stealing the packet before
hitting this point.
