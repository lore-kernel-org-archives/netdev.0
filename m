From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: use netif_receive_skb instead of netif_rx_ni
Date: Wed, 12 Feb 2014 15:40:36 +0800
Message-ID: <52FB2574.4070004@redhat.com>
References: <52FA32C5.9040601@huawei.com> <52FB066E.1020006@redhat.com> <52FB18B8.4070401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Qin Chuanyu <qinchuanyu@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786AbaBLHk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 02:40:59 -0500
In-Reply-To: <52FB18B8.4070401@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2014 02:46 PM, Qin Chuanyu wrote:
> On 2014/2/12 13:28, Jason Wang wrote:
>
>> A question: without NAPI weight, could this starve other net devices=
?
> tap xmit skb use thread context=EF=BC=8Cthe poll func of physical nic=
 driver
> could be called in softirq context without change.
>
> I had test it by binding vhost thread and physic nic interrupt on the
> same vcpu, use netperf xmit udp, test model is VM1-Host1-Host2.
>
> if only VM1 xmit skb, the top show as below :
> Cpu1 :0.0%us, 95.0%sy, 0.0%ni, 0.0%id,  0.0%wa, 0.0%hi, 5.0%si,  0.0%=
st
>
> then use host2 xmit skb to VM1, the top show as below :
> Cpu1 :0.0%us, 41.0%sy, 0.0%ni, 0.0%id,  0.0%wa, 0.0%hi, 59.0%si, 0.0%=
st
>
> so I think there is no problem with this change.

Yes, I realize it was ok after Eric's comment.

Thanks
