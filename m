From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sun, 17 Nov 2013 23:20:02 +0200
Message-ID: <CAJZOPZJGithUYAdCnKzG4q1MsntMo0GaUHqHf7sa6N0MpKk5+Q@mail.gmail.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	<1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
	<1384708847.8604.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuw1VUtafKVnBOKAy+rNyKDYnDsst8ygwqEtKX75w96Q-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:43695 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3KQVUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 16:20:03 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so1094204pbc.24
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 13:20:02 -0800 (PST)
In-Reply-To: <CAMEtUuw1VUtafKVnBOKAy+rNyKDYnDsst8ygwqEtKX75w96Q-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 17, 2013 , Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Sun, Nov 17, 2013 , Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Sat, 2013-11-16 , Alexei Starovoitov wrote:

>>> In case of VMs sending gso packets over tap and tunnel in the host,
>>> ip_forward is not in the picture.

>> I was specifically answering to #2 which should use ip forwarding, of
>> course. Note that my patch was a POC : We have many other places where
>> the typical MTU check is simply disabled as soon as skb is GSO.

> I don't think #2 will do ip_forward either. veth goes into a bridge
> and vxlan just adds encap.

Eric, do we have concensus here that this #2 of veth --> bridge -->
vxlan --> NIC will not go through ip_forward?!

Anyway, I tried your patch and didn't see notable improvement on my
tests. The tests I did few days ago were over 3.10.19 to have more
stable ground... moving to 3.12.0 and net-next today, the baseline
performance became worse, in the sense that if a bit of simplified env
of bridge --> vxlan --> NIC with many iperf client threads yielded
similar throughput as vxlan --> NIC or bridge --> NIC, with net-next
its not the case. If you have 10Gbs or 40Gbs NICs, even without HW TCP
offloads for VXLAN, you might be able to see that on your setups.
