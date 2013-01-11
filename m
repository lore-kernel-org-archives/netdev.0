From: Paul Pearce <pearce@cs.berkeley.edu>
Subject: Re: [tcpdump-workers] [PATCH net 1/2] net: dev_queue_xmit_nit: fix
 skb->vlan_tci field value
Date: Thu, 10 Jan 2013 18:37:19 -0800
Message-ID: <CAOUgPvSpMmsLpiwmnxwFx9p+B=KOG5VqjNvu_+54hLcBPNK4Cg@mail.gmail.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
 <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
 <1357712850.27446.28.camel@edumazet-glaptop> <CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
 <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
 <1357761063.27446.60.camel@edumazet-glaptop> <32117.1357868869@sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	edumazet <edumazet@google.com>,
	tcpdump-workers <tcpdump-workers@lists.tcpdump.org>,
	dborkman <dborkman@redhat.com>
To: Michael Richardson <mcr@sandelman.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:46963 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab3AKCiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 21:38:00 -0500
Received: by mail-oa0-f52.google.com with SMTP id o6so1364594oag.11
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 18:37:59 -0800 (PST)
In-Reply-To: <32117.1357868869@sandelman.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> My opinion as a kernel developer is that the network tap is here to have
>> a copy of the exact frame given to the _device_.

> Good: as someone who spends lots of time with tcpdump doing both network
> and protocol diagnostics, it's really important to see exactly there.
> If that means turning off some hardware offload in order to get the
> intact 1p header, then that may be fine for many situations.
> (At 10G, on a live router... well...)

I agree as well.

But I think Ani's point was that for RX packets, as of commit
bcc6d47903612c3861201cc3a866fb604f26b8b2, the filters are not
getting exactly what's "on the wire." Independent of hardware
acceleration the vlan headers are being stripped off and skb->vlan_tci
is being set. That's was the origin of this whole mess.

The msg from that commit reads in part:
> Vlan untagging happens early in __netif_receive_skb so the rest of
> code (ptype_all handlers, rx_handlers) see the skb like it was
> untagged by hw.

His confusion (which I share) is why it's acceptable to have this
behavior of removing headers and setting skb->vlan_tci (regardless of
hardware acceleration) on the RX path but not also set skb->vlan_tci
on the TX path.

Indepdent of proposed userspace or PACKET_AUXDATA solutions,
clarification on the RX skb->vlan_tci behavior would be appreciated.

My knowledge of this code is quite limited so it's entirely possible
I'm off base here. If so please tell me.
-Paul
