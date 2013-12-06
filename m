From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Fri, 6 Dec 2013 11:30:37 +0200
Message-ID: <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
References: <529DF340.70602@mellanox.com>
	<1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com>
	<alpine.LFD.2.03.1312031310140.23893@intel.com>
	<CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<alpine.LFD.2.03.1312031500020.570@intel.com>
	<CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
	<alpine.LFD.2.03.1312031626400.7539@intel.com>
	<CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
	<alpine.LFD.2.03.1312040113290.14367@intel.com>
	<CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
	<52A197DF.5010806@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:36405 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab3LFJai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:30:38 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so749406pbc.39
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 01:30:37 -0800 (PST)
In-Reply-To: <52A197DF.5010806@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 04/12/2013 11:41, Or Gerlitz wrote:
> On Wed, Dec 4, 2013 at 11:24 AM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
>
>> And just for the record,
>> you are seeing (SKB_UDP_TUNNEL | SKB_GSO_TCPV4) as 0x201 while I was
>> seeing it as 0x81 because commit 61c1db7fae "ipv6: sit: add GSO/TSO
>> support" pushed the SKB_UDP_TUNNEL two bits left, and I had done my tests
>> before it.
>
> indeed, also, on what kernel did you conducted your tests which you managed
> to WA the problem with unsetting that bit?


Hi Joseph,

Really need your response here --

1. on which kernel did you manage to get along fine vxlan performance
wise with this hack?

2. did the hack helped for both veth host traffic or only on PV VM traffic?

Currently it doesn't converge with 3.12.x or net.git, with veth/vxlan
the DODGE bit isn't set when looking on the skb in the vxlan xmit
time, so there's nothing for me to hack there. For VMs without
unsetting the bit things don't really work, but unsetting it for
itself so far didn't get me far performance wise.

BTW guys, I saw the issues with both bridge/openvswitch configuration
- seems that we might have here somehow large breakage of the system
w.r.t vxlan traffic for rates that go over few Gbs -- so would love to
get feedback of any kind from the people that were involved with vxlan
over the last months/year.

Or.

net.git]# grep -rn  SKB_GSO_DODGY drivers/net/ net/ipv4 net/core
drivers/net/macvtap.c:585:              skb_shinfo(skb)->gso_type |=
SKB_GSO_DODGY;
drivers/net/tun.c:1135:         skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
drivers/net/virtio_net.c:497:           skb_shinfo(skb)->gso_type |=
SKB_GSO_DODGY;
drivers/net/xen-netback/netback.c:1146: skb_shinfo(skb)->gso_type |=
SKB_GSO_DODGY;
drivers/net/xen-netfront.c:823: skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
net/ipv4/af_inet.c:1264:                       SKB_GSO_DODGY |
net/ipv4/tcp_offload.c:56:                             SKB_GSO_DODGY |
net/ipv4/gre_offload.c:40:                                SKB_GSO_DODGY |
net/ipv4/udp_offload.c:53:              if (unlikely(type &
~(SKB_GSO_UDP | SKB_GSO_DODGY |
net/core/dev.c:2694:            if (shinfo->gso_type & SKB_GSO_DODGY)
