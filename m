From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: rename sysfs symlinks on device name
 change
Date: Tue, 14 Jan 2014 20:14:17 +0100
Message-ID: <20140114191417.GB9942@redhat.com>
References: <1389717360-13920-1-git-send-email-vfalico@redhat.com>
 <1389717360-13920-3-git-send-email-vfalico@redhat.com>
 <CAHA+R7N=iFAGqoRuL8HD3SnkmH-dMPpUCkrJkLEGd1SPTbe4Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbaANTRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 14:17:21 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7N=iFAGqoRuL8HD3SnkmH-dMPpUCkrJkLEGd1SPTbe4Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 10:30:56AM -0800, Cong Wang wrote:
>On Tue, Jan 14, 2014 at 8:36 AM, Veaceslav Falico <vfalico@redhat.com> wrote:
>> +void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
>> +{
>> +       struct netdev_adjacent *iter;
>> +
>> +       list_for_each_entry(iter, &dev->adj_list.upper, list) {
>> +               netdev_adjacent_sysfs_del(iter->dev, oldname,
>> +                                         &iter->dev->adj_list.lower);
>> +               netdev_adjacent_sysfs_add(iter->dev, dev,
>> +                                         &iter->dev->adj_list.lower);
>> +       }
>> +
>> +       list_for_each_entry(iter, &dev->adj_list.lower, list) {
>> +               netdev_adjacent_sysfs_del(iter->dev, oldname,
>> +                                         &iter->dev->adj_list.upper);
>> +               netdev_adjacent_sysfs_add(iter->dev, dev,
>> +                                         &iter->dev->adj_list.upper);
>> +       }
>> +}
>> +EXPORT_SYMBOL(netdev_adjacent_rename_links);
>
>Since it is only used within net/core/dev.c, why do you make it extern
>and export it? It can become static.

Hm, good point, exported it automatically, didn't realise that dev_rename()
is also in dev.c.

Will send v2.
