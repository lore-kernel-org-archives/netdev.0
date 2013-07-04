From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core/dev: set pkt_type after eth_type_trans() in
 dev_forward_skb()
Date: Thu, 04 Jul 2013 14:57:12 -0700 (PDT)
Message-ID: <20130704.145712.2078075601927798473.davem@davemloft.net>
References: <0324dc4a3a7740e4766e16539f4ed41b356f991d.1372764542.git.yamahata@valinux.co.jp>
	<20130702.160005.59343488202291094.davem@davemloft.net>
	<51D43B00.9030801@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org,
	murphy.mccauley@gmail.com, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, kaber@trash.net, honkiko@gmail.com,
	ramirose@gmail.com, tparkin@katalix.com, xiyou.wangcong@gmail.com,
	pshelar@nicira.com, jesse@nicira.com, dev@openvswitch.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832Ab3GDV5N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 17:57:13 -0400
In-Reply-To: <51D43B00.9030801@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 03 Jul 2013 16:53:52 +0200

> Le 03/07/2013 01:00, David Miller a =E9crit :
>> From: Isaku Yamahata <yamahata@valinux.co.jp>
>> Date: Tue,  2 Jul 2013 20:30:10 +0900
>>
>>> The dev_forward_skb() assignment of pkt_type should be done
>>> after the call to eth_type_trans().
>>>
>>> ip-encapsulated packets can be handled by localhost. But skb->pkt_t=
ype
>>> can be PACKET_OTHERHOST when packet comes via veth into ip tunnel
>>> device.
>>> In that case, the packet is dropped by ip_rcv().
>>> Although this example uses gretap. l2tp-eth also has same issue.
>>> For l2tp-eth case, add dummy device for ip address and ip l2tp
>>> command.
>>   ...
>>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
>>
>> Applied, but I had to adjust the patch because in net-next we use
>> a new helper function (skb_scrub_packet()) to clear things out from
>> dev_forward_skb().
> What about calling skb_scrub_packet() after eth_type_trans()?
>=20
> I wonder if the same problem may happen the day gre will support
> x-netns,
> because skb_scrub_packet() is also called before eth_type_trans() in
> ip_tunnel_rcv().

That's a fine suggestion, I was just being overly conservative in my
forward-porting of his patch.
