From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 06:49:20 -0800
Message-ID: <1390920560.28432.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E766D4.4070901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jasowang@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Peter Klausler <pmk@google.com>
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <52E766D4.4070901@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-01-28 at 16:14 +0800, Qin Chuanyu wrote:
> according perf test result=EF=BC=8CI found that there are 5%-8% cpu c=
ost on=20
> softirq by use netif_rx_ni called in tun_get_user.
>=20
> so I changed the function which cause skb transmitted more quickly.
> from
> 	tun_get_user	->
> 		 netif_rx_ni(skb);
> to
> 	tun_get_user	->
> 		rcu_read_lock_bh();
> 		netif_receive_skb(skb);
> 		rcu_read_unlock_bh();

No idea why you use rcu here ?

>=20
> The test result is as below:
> 	CPU: Intel(R) Xeon(R) CPU E5620  @ 2.40GHz
> 	NIC: intel 82599
> 	Host OS/Guest OS:suse11sp3
> 	Qemu-1.6
> 	netperf udp 512(VM tx)
> 	test model: VM->host->host
>=20
> 	modified before : 2.00Gbps 461146pps
> 	modified after  : 2.16Gbps 498782pps
>=20
> 8% performance gained from this change,
> Is there any problem for this patch ?

http://patchwork.ozlabs.org/patch/52963/




