From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 RFC] 8139cp: Fix GSO MSS handling
Date: Sun, 27 Sep 2015 22:37:49 -0700
Message-ID: <CALx6S36pah3B7AgqAzpfExA8ehH3VMLzWF275sH0OA815e3TUQ@mail.gmail.com>
References: <1442996049.36485.32.camel@infradead.org>
	<20150923.105812.149257816141624869.davem@davemloft.net>
	<1443037530.74600.29.camel@infradead.org>
	<20150923.144808.886375927698238398.davem@davemloft.net>
	<1443045602.74600.33.camel@infradead.org>
	<20150923232931.GA8365@electric-eye.fr.zoreil.com>
	<1443085112.74600.53.camel@infradead.org>
	<1443091102.74600.70.camel@infradead.org>
	<1443096325.29850.151.camel@edumazet-glaptop2.roam.corp.google.com>
	<1443097898.74600.91.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33495 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbbI1Fhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 01:37:50 -0400
Received: by iofh134 with SMTP id h134so163803731iof.0
        for <netdev@vger.kernel.org>; Sun, 27 Sep 2015 22:37:50 -0700 (PDT)
In-Reply-To: <1443097898.74600.91.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 5:31 AM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Thu, 2015-09-24 at 05:05 -0700, Eric Dumazet wrote:
>>
>> Right, netif_skb_features() only has the following checks :
>>
>> if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
>>     features &= ~NETIF_F_GSO_MASK;
>>
>> But now we have .ndo_features_check() we could remove this generic
>> check from fast path.
>
> Perhaps so, yes.
>
> Any thoughts on the other reason I was staring at this same code path
> this week? I am able to reliably feed inappropriate packets to a
> NETIF_F_IP_CSUM-capable device with the test program at
> http://bombadil.infradead.org/~dwmw2/raw.c (and equivalent code paths
> via virtio_net, tun and others).
>
> They're *supposed* to get checksummed by software if the device can't
> cope, but netif_skb_features() returns the wrong answer, so we fail to
> do that and they're fed with CHECKSUM_PARTIAL to a device which can't
> handle them. Causing a WARN() or a BUG() or a silent corruption,
> depending on the driver.
>
Which drivers are doing this? It is up to the driver to determine
whether a particular packet being sent can have checksum offloaded to
the device. If it cannot offload the checksum it must call
skb_checksum_help.

Tom

> --
> dwmw2
>
