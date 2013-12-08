From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 22:12:32 +0200
Message-ID: <CAJZOPZJACTX1giFudwbBqppE_GyQVzamNqiO61vL3d0eoaJoFQ@mail.gmail.com>
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
	<alpine.LFD.2.03.1312060205220.3499@intel.com>
	<CAJZOPZ+o=gjhmyvDwVCO8pOTJSf8aKLfB9sqjmbW-1+YjLLAaQ@mail.gmail.com>
	<alpine.LFD.2.03.1312080951160.23234@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:62640 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab3LHUMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 15:12:33 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so4113419pbc.10
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 12:12:32 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312080951160.23234@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:

>> What I saw is that if I leave the DODGY bit set, practically things
>> don't work at all, its not that some packets are dropped, was that
>> what you saw?

> What I saw was gso packets badly segmented, causing many re-transmissions
> and dropping the performance to a few MB/s.

Yes, in my testbed upto about 400Mbs (b not B..., yes!)


>> Also, did you hack/modified the VM NIC MTU to take into the account
>> the encapsulation overhead?

> The virtio interfaces I used had MTU 1500, but the MTU of the physical NIC
> was increased to 1600.

mmm, that's sort of equivalent, but zero touch VM wise, nice!


> I have only noticed this with the offloads on. Turning off encapsuation
> TSO off, would simply make the gso's to get segmented in dev_hard_xmit()
> as expected.

mmm, I am not sure this is the case with kernels > 3.10.x, but I'd
like to double check that, basically, its possible that I didn't make
sure to always have "proper" MTU at the VM @ all times.

Also, did you see the unsimilarity between TX/RX which I reported
earlier today, that is accelerated TX from single VM can go as far as
> 30Gbs while RX to single VM or even multiple VMs doesn't go beyond
5-6Gbs probably as of the lack of GRO?
