From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 16:14:12 +0800
Message-ID: <52E766D4.4070901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"Anthony Liguori" <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

according perf test result=EF=BC=8CI found that there are 5%-8% cpu cos=
t on=20
softirq by use netif_rx_ni called in tun_get_user.

so I changed the function which cause skb transmitted more quickly.
from
	tun_get_user	->
		 netif_rx_ni(skb);
to
	tun_get_user	->
		rcu_read_lock_bh();
		netif_receive_skb(skb);
		rcu_read_unlock_bh();

The test result is as below:
	CPU: Intel(R) Xeon(R) CPU E5620  @ 2.40GHz
	NIC: intel 82599
	Host OS/Guest OS:suse11sp3
	Qemu-1.6
	netperf udp 512(VM tx)
	test model: VM->host->host

	modified before : 2.00Gbps 461146pps
	modified after  : 2.16Gbps 498782pps

8% performance gained from this change,
Is there any problem for this patch ?

