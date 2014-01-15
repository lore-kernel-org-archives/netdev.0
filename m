From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 2/2] net: rename sysfs symlinks on device
 name change
Date: Wed, 15 Jan 2014 03:59:00 +0100
Message-ID: <20140115025900.GB1554@redhat.com>
References: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
 <1389733131-15390-3-git-send-email-vfalico@redhat.com>
 <52D5F776.4090101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbaAODCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 22:02:07 -0500
Content-Disposition: inline
In-Reply-To: <52D5F776.4090101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 10:50:30AM +0800, Ding Tianhong wrote:
>On 2014/1/15 4:58, Veaceslav Falico wrote:
...snip...
>> +void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
>> +{
>> +	struct netdev_adjacent *iter;
>> +
>> +	list_for_each_entry(iter, &dev->adj_list.upper, list) {
>> +		netdev_adjacent_sysfs_del(iter->dev, oldname,
>> +					  &iter->dev->adj_list.lower);
>> +		netdev_adjacent_sysfs_add(iter->dev, dev,
>> +					  &iter->dev->adj_list.lower);
>> +	}
>> +
>> +	list_for_each_entry(iter, &dev->adj_list.lower, list) {
>> +		netdev_adjacent_sysfs_del(iter->dev, oldname,
>> +					  &iter->dev->adj_list.upper);
>> +		netdev_adjacent_sysfs_add(iter->dev, dev,
>> +					  &iter->dev->adj_list.upper);
>> +	}
>> +}
>> +
>
>why no all_adj_list, only adj_list?
>
>I think you have add the dev to the upper_dev's upper_dev by all_adj_list, and lower_dev, so you have to check them.

symlinks are created only for neighbour adjacent devices, which are in
adj_list.*, and are not created for all_adj_list.* devices, which contains
a 'full view' list of all adjacent devices.

>
>Regards
>Ding
>
>>  void *netdev_lower_dev_get_private(struct net_device *dev,
>>  				   struct net_device *lower_dev)
>>  {
>>
>
>
