From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 net-next 2/2] net: rename sysfs symlinks on device
 name change
Date: Wed, 15 Jan 2014 11:09:53 +0800
Message-ID: <52D5FC01.2060707@huawei.com>
References: <1389733131-15390-1-git-send-email-vfalico@redhat.com> <1389733131-15390-3-git-send-email-vfalico@redhat.com> <52D5F776.4090101@huawei.com> <20140115025900.GB1554@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:24606 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbaAODKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 22:10:50 -0500
In-Reply-To: <20140115025900.GB1554@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/15 10:59, Veaceslav Falico wrote:
> On Wed, Jan 15, 2014 at 10:50:30AM +0800, Ding Tianhong wrote:
>> On 2014/1/15 4:58, Veaceslav Falico wrote:
> ...snip...
>>> +void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
>>> +{
>>> +    struct netdev_adjacent *iter;
>>> +
>>> +    list_for_each_entry(iter, &dev->adj_list.upper, list) {
>>> +        netdev_adjacent_sysfs_del(iter->dev, oldname,
>>> +                      &iter->dev->adj_list.lower);
>>> +        netdev_adjacent_sysfs_add(iter->dev, dev,
>>> +                      &iter->dev->adj_list.lower);
>>> +    }
>>> +
>>> +    list_for_each_entry(iter, &dev->adj_list.lower, list) {
>>> +        netdev_adjacent_sysfs_del(iter->dev, oldname,
>>> +                      &iter->dev->adj_list.upper);
>>> +        netdev_adjacent_sysfs_add(iter->dev, dev,
>>> +                      &iter->dev->adj_list.upper);
>>> +    }
>>> +}
>>> +
>>
>> why no all_adj_list, only adj_list?
>>
>> I think you have add the dev to the upper_dev's upper_dev by all_adj_list, and lower_dev, so you have to check them.
> 
> symlinks are created only for neighbour adjacent devices, which are in
> adj_list.*, and are not created for all_adj_list.* devices, which contains
> a 'full view' list of all adjacent devices.
> 

Yes, it return when found adj, I miss it.

>>
>> Regards
>> Ding
>>
>>>  void *netdev_lower_dev_get_private(struct net_device *dev,
>>>                     struct net_device *lower_dev)
>>>  {
>>>
>>
>>
> 
> 
