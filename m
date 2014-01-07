From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net 2/2] net: core: explicitly select a txq before doing
 l2 forwarding
Date: Tue, 07 Jan 2014 00:37:31 -0800
Message-ID: <52CBBCCB.6030000@intel.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <1388978467-2075-2-git-send-email-jasowang@redhat.com> <52CBB94D.6010405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CBB94D.6010405@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]

>>
>> +int dfwd_direct_xmit(struct sk_buff *skb, struct net_device *dev,
>> +             void *accel_priv)
>> +{
>> +    struct netdev_queue *txq;
>> +    int ret = NETDEV_TX_BUSY;
>> +    int index;
>> +
>> +    BUG_ON(!dev->netdev_ops->ndo_dfwd_select_queue);
>> +    index =    dev->netdev_ops->ndo_dfwd_select_queue(dev, skb,
>> +                               accel_priv);
>> +
>> +    local_bh_disable();
>> +
>> +    skb_set_queue_mapping(skb, index);
>
> How about replacing the index calculation and skb_set_queue_mapping with
> netdev_pick_tx(). Then we don't need to add a new op and the existing
> XPS, tx hash and select_queue() op works.
>

Sorry for the noise that was dumb it wouldn't work.
