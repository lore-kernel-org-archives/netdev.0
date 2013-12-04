From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 10:35:18 +0200
Message-ID: <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
References: <529DF340.70602@mellanox.com>
	<1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com>
	<alpine.LFD.2.03.1312031310140.23893@intel.com>
	<CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<alpine.LFD.2.03.1312031500020.570@intel.com>
	<CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
	<alpine.LFD.2.03.1312031626400.7539@intel.com>
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
Received: from mail-pd0-f181.google.com ([209.85.192.181]:62742 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081Ab3LDIfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 03:35:19 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so21798879pdj.40
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 00:35:18 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312031626400.7539@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 2:35 AM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:

> I was printing the gso_type in vxlan_xmit_skb(), right before
> iptunnel_xmit() gets called (I was focus UDPv4 encap only). Then I saw the
> gso_type was different when a VM was involved and when it was not
> (although I was transmitting exactly the same packet), and then I replaced
> my printk with something like skb_shinfo(skb)->gso_type = <the gso type I had
> for non-VM skb> and it all worked.
>
> Then I looked into what was different between the two gso_types and the
> only difference was that SKB_GSO_DODGY was set when Tx'ing from the VM.
> I am sure I could have been more delicate with the aproach, but hey, it
> worked for me.
>
> I would be curious to see if this is the same issue as mine. It seems like it is.

nope! with the latest net tree, after handle_offloads is called in
vxlan_xmit_skb and before iptunnel_xmit is invoked,
skb_shinfo(skb)->gso_type is either 0 or 0x201 which is
(SKB_GSO_UDP_TUNNEL | SKB_GSO_TCPV4) and its the same value whether
the session runs over veth device or directly over the bridge, where
over veth and > 1 stream we see drops, bad perf, etc.

I am very interested in the VM case too, so will check it out and let you know.
