From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 11:41:34 +0200
Message-ID: <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:62144 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab3LDJlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 04:41:35 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so22013765pdj.16
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 01:41:35 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312040113290.14367@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 11:24 AM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:
> On Wed, 4 Dec 2013, Or Gerlitz wrote:

>> nope! with the latest net tree, after handle_offloads is called in
>> vxlan_xmit_skb and before iptunnel_xmit is invoked,
>> skb_shinfo(skb)->gso_type is either 0 or 0x201 which is
>> (SKB_GSO_UDP_TUNNEL | SKB_GSO_TCPV4) and its the same value whether
>> the session runs over veth device or directly over the bridge, where
>> over veth and > 1 stream we see drops, bad perf, etc.
>> I am very interested in the VM case too, so will check it out and let you know.

> Ok, I was really hoping that would be the same...

So when running traffic from VM I do see SKB_GSO_DODGY bit being set!
my environment for
running VMs with sane peformance was screwed  a bit, I will bring it
up later today and see if unsetting the bit helps.


> And just for the record,
> you are seeing (SKB_UDP_TUNNEL | SKB_GSO_TCPV4) as 0x201 while I was
> seeing it as 0x81 because commit 61c1db7fae "ipv6: sit: add GSO/TSO
> support" pushed the SKB_UDP_TUNNEL two bits left, and I had done my tests
> before it.

indeed, also, on what kernel did you conducted your tests which you
managed to WA the problem
with unsetting that bit?
