From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci
 field value
Date: Wed, 09 Jan 2013 11:51:03 -0800
Message-ID: <1357761063.27446.60.camel@edumazet-glaptop>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
	 <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
	 <1357712850.27446.28.camel@edumazet-glaptop>
	 <CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
	 <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tcpdump-workers@lists.tcpdump.org,
	Paul Pearce <pearce@cs.berkeley.edu>, netdev@vger.kernel.org,
	dborkman <dborkman@redhat.com>, edumazet <edumazet@google.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:48356 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab3AITvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 14:51:06 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so905308dae.21
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 11:51:05 -0800 (PST)
In-Reply-To: <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-09 at 11:27 -0800, Ani Sinha wrote:

> This is wrong. Accelerated or not, the kernel code was organized to
> have the tags in the packet aux data. So I think this is how user land
> should be coded as well.

You have your opinion, thats good.

My opinion as a kernel developer is that the network tap is here to have
a copy of the exact frame given to the _device_.

Because in the end, users will complain to netdev, giving us tcpdump
traces. And if these traces have nothing to do with what is given to the
device, they are almost useless.

If you want other taps, and catch frames before/after various netfilter
hooks, segmentations, vlan accel, tunnels, or before GRO layer, thats a
totally different request.

A packet can be modified by a lot of layers in the kernel.

And yes, BPF filters can be incredibly complex, but it appears kernel is
not a piece of cake.
