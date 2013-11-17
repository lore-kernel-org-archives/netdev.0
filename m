From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sun, 17 Nov 2013 09:20:47 -0800
Message-ID: <1384708847.8604.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	 <1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:37028 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab3KQRUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 12:20:49 -0500
Received: by mail-pb0-f44.google.com with SMTP id xa7so67623pbc.31
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 09:20:49 -0800 (PST)
In-Reply-To: <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 23:31 -0800, Alexei Starovoitov wrote:

> In case of VMs sending gso packets over tap and tunnel in the host,
> ip_forward is not in the picture.
> 

I was specifically answering to #2 which should use ip forwarding, of
course. Note that my patch was a POC : We have many other places where
the typical MTU check is simply disabled as soon as skb is GSO.

> when host mtu doesn't account for overhead of tunnel, the neat trick
> we can do is to decrease gso_size while adding tunnel header.

That would be very broken to change gso_size, this breaks DF flag
semantic. You need to send an ICMP, and the sender will take appropriate
action.

GRO + GSO request that forwarded segments are the same than incoming
ones. It's not like a proxy that can chose to aggregate as it wants.
