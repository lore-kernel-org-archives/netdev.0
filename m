From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 16:34:35 -0800
Message-ID: <CAMEtUuzBpiZEzSxK7315dpJWT6LVb09hFNABUktq_0HMu9bhcQ@mail.gmail.com>
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
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52645 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab3LDAeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 19:34:37 -0500
Received: by mail-wg0-f46.google.com with SMTP id m15so14324063wgh.25
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 16:34:35 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312031626400.7539@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 4:35 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:
>
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

hmm. dodgy should be a normal path from vm.
kvm suppose to negotiate vnet_hdr for tap/macvtap and corresponding
driver will be remapping virtio_net_gso* flags into skb_gso_* flags
plus gso_dodgy.
