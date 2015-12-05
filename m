From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/4] net: mvneta: Spread out the TX queues
 management on all CPUs
Date: Sat, 05 Dec 2015 17:24:37 -0500 (EST)
Message-ID: <20151205.172437.1660871557891874317.davem@davemloft.net>
References: <1449254700-32685-1-git-send-email-gregory.clement@free-electrons.com>
	<1449254700-32685-5-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKe32dUP0jTkjJkWF=tpJDkR_J3Z5aSR5YT8rJtoMAKyjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	jason@lakedaemon.net, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	ezequiel.garcia@free-electrons.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	nadavh@marvell.com, simon.guinot@sequanux.org,
	maxime.ripard@free-electrons.com,
	boris.brezillon@free-electrons.com, linux@arm.linux.org.uk,
	w@1wt.eu, arnd@arndb.de
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKe32dUP0jTkjJkWF=tpJDkR_J3Z5aSR5YT8rJtoMAKyjA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>
Date: Sat, 5 Dec 2015 20:14:31 +0100

> Hi Gregory,
> 
>> @@ -1824,13 +1835,16 @@ error:
>>  static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>>  {
>>         struct mvneta_port *pp = netdev_priv(dev);
>> -       u16 txq_id = skb_get_queue_mapping(skb);
>> +       u16 txq_id = smp_processor_id() % txq_number;
> 
> I think it may be ok to bind TXQs to different CPUs, but I don't think
> that replacing skb_get_queue_mapping by in fact smp_processor_id() is
> the best idea. This way you use only 2 TXQs on A385 and 4 TXQs on AXP.
> There are HW mechanisms like WRR or EJP that provide balancing for
> egress, so let's better keep all 8.

Also it is possible for other parts of the stack to set the SKB queue
mapping and you must respect that setting rather than override it.
