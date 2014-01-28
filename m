From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 10:34:59 +0200
Message-ID: <20140128083459.GB16833@redhat.com>
References: <52E766D4.4070901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jasowang@redhat.com, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754881AbaA1IjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 03:39:10 -0500
Content-Disposition: inline
In-Reply-To: <52E766D4.4070901@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 04:14:12PM +0800, Qin Chuanyu wrote:
> according perf test result=EF=BC=8CI found that there are 5%-8% cpu c=
ost on
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

I think it's okay - IIUC this way we are processing xmit directly
instead of going through softirq.
Was meaning to try this - I'm glad you are looking into this.

Could you please check latency results?


--=20
MST
