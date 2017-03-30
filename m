From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [PATCH] ixgbe: Check for skb->queue_mapping
Date: Wed, 29 Mar 2017 18:47:34 -0700
Message-ID: <30e773c1-1279-8a30-82c8-d008d853e866@oracle.com>
References: <1490831714-6184-1-git-send-email-tushar.n.dave@oracle.com>
 <1490833787.24891.52.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25606 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdC3BtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 21:49:06 -0400
In-Reply-To: <1490833787.24891.52.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/29/2017 05:29 PM, Eric Dumazet wrote:
> On Wed, 2017-03-29 at 16:55 -0700, Tushar Dave wrote:
>> There are events seen where skb->queue_mapping value is greater than
>> adapter->num_tx_queue. In such cases, adapter->tx_ring becomes invalid
>> (null) and xmit results in kernel panic.
>>
>> One such event is running netconsole and enabling VF on the same device.
>> Or running netconsole and changing number of tx queues via ethtool on
>> same device.
>>
>> This patch adds check for skb->queue_mapping and uses simple arithmetic
>> to select available tx queue from driver.
>
> We are not going to fix all multi queue drivers, for something that
> seems to be a generic issue higher in the stack.
I have fixed it in ixgbe,i40e drivers because I see Intel igb driver
does similar thing. But I agree that the core issue lies up in the stack.

For the information, I found that this issue only affecting skbs that
are coming from direct xmit path (netdev_start_xmit) that netconsole,
pktgen , af_packet etc,. uses. skbs coming from qdisc already have this
fixed in stack. (http://lists.openwall.net/netdev/2010/07/01/58)

Thanks.

-Tushar


>
>
>
