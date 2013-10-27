From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in bonding
Date: Sun, 27 Oct 2013 22:10:48 +0100
Message-ID: <20131027211048.GA557@redhat.com>
References: <52688F33.30904@huawei.com>
 <20131027.163712.1324471504006808112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab3J0VNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 17:13:11 -0400
Content-Disposition: inline
In-Reply-To: <20131027.163712.1324471504006808112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 27, 2013 at 04:37:12PM -0400, David Miller wrote:
>From: Ding Tianhong <dingtianhong@huawei.com>
>Date: Thu, 24 Oct 2013 11:08:35 +0800
>
>> The slave list will add and del by bond_master_upper_dev_link() and bond_upper_dev_unlink(),
>> which will call call_netdevice_notifiers(), even it is safe to call it in write bond lock now,
>> but we can't sure that whether it is safe later, because other drivers may deal NETDEV_CHANGEUPPER
>> in sleep way, so I didn't admit move the bond_upper_dev_unlink() in write bond lock.
>>
>> now the bond_for_each_slave only protect by rtnl_lock(), maybe use bond_for_each_slave_rcu is a good
>> way to protect slave list for bond, but as a system slow path, it is no need to transform bond_for_each_slave()
>> to bond_for_each_slave_rcu() in slow path, so in the patchset, I will remove the unused read bond lock
>> for monitor function, maybe it is a better way, I will wait to accept any relay for it.
>>
>> Thanks for the Veaceslav Falico opinion.
>>
>> v2: add and modify commit for patchset and patch, it will be the first step for the whole patchset.
>
>Series applied, thanks.
David,

Either I've missed something, or I don't understand something. I've
explicitly Nacked it - http://www.spinics.net/lists/netdev/msg254998.html .

All the changelogs for the patches are *the same*, and, while they try to
explain what's done overall, the don't explain what's done per-patch, why
it's done and why is it safe to move those locks around.

And, while the code changes are small, they touch really sensitive stuff -
locking, and not only bond->lock, but also rtnl. Without proper changelogs
it's really hard to review them per-patch, that's why I've asked for them
several times.

Anyway, care to explain what did I miss?

Thank you!
