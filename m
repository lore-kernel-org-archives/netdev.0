From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Sat, 3 May 2014 08:58:31 +0800
Message-ID: <CAABZP2z4OQ5fHDDAJPU5RAteBFK9wwmCqRSg8Knp635auCj4ZA@mail.gmail.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
	<5363C545.90600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, steffen.klassert@secunet.com,
	fan.du@windriver.com, dborkman@redhat.com,
	Mathias Krause <minipli@googlemail.com>, tgraf@suug.ch,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5363C545.90600@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank Sergei for reviewing.

I think
On Sat, May 3, 2014 at 12:18 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>> +
>> +       if (pkt_dev->clone_skb && is_vlan_dev(odev)) {
>> +               nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
>> +               ret = -ENOMEM;
>> +               if (nskb)
>> +                       ret = (*xmit)(nskb, odev);
if (is_vlan_dev(odev) && pkt_dev->clone_skb) {
        nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
        ret = -ENOMEM;
        if (nskb)
             ret = (*xmit)(nskb, odev);
}
>
and

case NETDEV_TX_LOCKED:
case NETDEV_TX_BUSY:
     /* Retry it next time */
     atomic_dec(&(pkt_dev->skb->users));
     if (is_vlan_dev(odev) && pkt_dev->clone_skb && nskb)
                 kfree_skb(nskb);
     else
                 atomic_dec(&(pkt_dev->skb->users));

is better, because is_vlan_dev(odev) is probably in  read most cache line.

Zhouyi
