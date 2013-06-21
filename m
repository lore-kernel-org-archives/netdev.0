From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: allow large number of tx queues
Date: Fri, 21 Jun 2013 00:12:30 -0700
Message-ID: <1371798750.3252.431.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
	 <1371623518.3252.267.camel@edumazet-glaptop>
	 <20130619091132.GA2816@redhat.com>
	 <1371635763.3252.289.camel@edumazet-glaptop>
	 <20130619154059.GA13735@redhat.com>
	 <1371657511.3252.324.camel@edumazet-glaptop>
	 <20130619180709.GA15017@redhat.com>
	 <1371716151.3252.390.camel@edumazet-glaptop>
	 <20130620083530.GA23909@redhat.com> <51C3F5AC.2090008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, davem@davemloft.net,
	hkchu@google.com, netdev <netdev@vger.kernel.org>,
	dwmw2@infradead.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:48855 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab3FUHMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 03:12:36 -0400
Received: by mail-ea0-f180.google.com with SMTP id k10so4422183eaj.39
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 00:12:35 -0700 (PDT)
In-Reply-To: <51C3F5AC.2090008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-21 at 14:41 +0800, Jason Wang wrote:

> 1K queues (about 80 pages) looks a little bit aggressive which means we
> may always fall back to vmalloc()?

1K queues looks like you should use 0 queue (LLTX) in fact, so that you
design the minimal percpu structure in the driver to fit the needs.

Using Qdisc, qith MQ, pfifo_fast, on 1000 'queues' is adding a fair
amount of overhead and memory usage.

For example, loopback driver only needs small percpu structure (16
bytes), as it immediately forward the packet into netif_rx() [ Which
also use a percpu area called softnet_data ]
