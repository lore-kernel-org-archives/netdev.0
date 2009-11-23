From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 15:38:06 +0100
Message-ID: <4B0A9E4E.9010804@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>  <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com> <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51201 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308AbZKWOiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:38:04 -0500
In-Reply-To: <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =E9crit :

> How is your smp_affinity mask's set?
>=20
> grep . /proc/irq/*/fiber1-*/../smp_affinity

=46irst, I tried default affinities (ffff)

Then I tried irqbalance... no more success.

Driver seems to try to handle all queues on one cpu on low trafic,
and possibly dynamically switches to a multi-cpu mode,
but as all interrupts are masked, we stay in=20
a NAPI context handling all queues.

And we let one cpu in flood/drops mode.




>=20
>=20
>> But only one CPU (CPU1) had a softirq running, 100%, and many frames
>> were dropped
>=20
> Just a hint, I use 'ethtool -S fiber1' to see how the packets gets
> distributed across the rx and tx queues.

They are correctly distributed

     rx_queue_0_packets: 14119644
     rx_queue_0_bytes: 847178640
     rx_queue_1_packets: 14126315
     rx_queue_1_bytes: 847578900
     rx_queue_2_packets: 14115249
     rx_queue_2_bytes: 846914940
     rx_queue_3_packets: 14118146
     rx_queue_3_bytes: 847088760
     rx_queue_4_packets: 14130869
     rx_queue_4_bytes: 847853268
     rx_queue_5_packets: 14112239
     rx_queue_5_bytes: 846734340
     rx_queue_6_packets: 14128425
     rx_queue_6_bytes: 847705500
     rx_queue_7_packets: 14110587
     rx_queue_7_bytes: 846635220
     rx_queue_8_packets: 14117350
     rx_queue_8_bytes: 847041000
     rx_queue_9_packets: 14125992
     rx_queue_9_bytes: 847559520
     rx_queue_10_packets: 14121732
     rx_queue_10_bytes: 847303920
     rx_queue_11_packets: 14120997
     rx_queue_11_bytes: 847259820
     rx_queue_12_packets: 14125576
     rx_queue_12_bytes: 847535854
     rx_queue_13_packets: 14118512
     rx_queue_13_bytes: 847110720
     rx_queue_14_packets: 14118348
     rx_queue_14_bytes: 847100880
     rx_queue_15_packets: 14118647
     rx_queue_15_bytes: 847118820



>=20
>=20
>=20
>> CLONE_SKB=3D"clone_skb 15"
>=20
> Be careful with to high clone, as my experience is it will send a bur=
st
> of clone_skb packets before the packet gets randomized again.

Yes, but 15 should be ok with 10Gb link  :)

Thanks
