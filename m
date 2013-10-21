From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 21 Oct 2013 17:27:51 +0800
Message-ID: <5264F397.50608@huawei.com>
References: <5264ECBC.2090208@huawei.com> <20131021091336.GB692@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:51793 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab3JUJ2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:28:14 -0400
In-Reply-To: <20131021091336.GB692@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/21 17:13, Veaceslav Falico wrote:
> On Mon, Oct 21, 2013 at 04:58:36PM +0800, Ding Tianhong wrote:
>> Hi:
>>
>> The Patch Set will remove the invalid lock for bond work queue and replace it
>> with rtnl lock, as read lock for bond could not protect slave list any more.
> 
> rtnl lock is a lot more expensive than bond lock, and not only for bond,
> but for all the networking stack.
> 
> Why is the bond->lock invalid? It correctly protects slaves from being
> modified concurrently.
> 
> I don't see the point in this patchset.
> 

yes, rtnl lock is a big lock, but I think bond->lock could not protect
bond_for_each_slave any more, am I miss something?

Ding

>>
>> Ding Tianhong (5):
>>  bonding: remove bond read lock for bond_mii_monitor()
>>  bonding: remove bond read lock for bond_alb_monitor()
>>  bonding: remove bond read lock for bond_loadbalance_arp_mon()
>>  bonding: remove bond read lock for bond_activebackup_arp_mon()
>>  bonding: remove bond read lock for bond_3ad_state_machine_handler()
>>
>> drivers/net/bonding/bond_3ad.c  |   9 ++--
>> drivers/net/bonding/bond_alb.c  |  20 ++------
>> drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
>> 3 files changed, 40 insertions(+), 89 deletions(-)
>>
>> -- 
>> 1.8.2.1
>>
>>
>>
> 
> 
