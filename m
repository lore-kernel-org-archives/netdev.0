From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 21:28:45 +0800
Message-ID: <57A9DA8D.3010407@huawei.com>
References: <20160808211530.GH22974@cork> <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork> <57A93D81.4030808@huawei.com>
 <20160809030956.GL22974@cork>
 <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>,
	=?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:58530 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932398AbcHIN3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 09:29:40 -0400
In-Reply-To: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/8/9 13:29, zhuyj wrote:
> Can we check slave_ops->ndo_set_mac_address?
> 
> 1476         if ((slave_ops->ndo_set_mac_address) &&
> (!bond->params.fail_over_mac ||
> 1477             BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
> 1478                 /* Set slave to master's mac address. The
> application already
> 1479 * set the master's mac address to that of the first slave
> 1480 */
> 1481                 memcpy(addr.sa_data, bond_dev->dev_addr,
> bond_dev->addr_len);
> 1482                 addr.sa_family = slave_dev->type;
> 1483                 res = dev_set_mac_address(slave_dev, &addr);
> 1484                 if (res) {
> 1485                         netdev_dbg(bond_dev, "Error %d calling
> set_mac_address\n", res);
> 1486                         goto err_restore_mtu;
> 1487                 }
> 1488         }
> 

This patch is a simple solution for this problem, but I don't think it is the right solution, the bond is a virtual device base on L2,
if the slave has no mac address, it will break the design principle, so we need to think more about it.

I think if the bonding dev has to support L3 virtual device, we need to add new bond features to distinguish the dev and make the
bond xmit and transfer without the mac address.

Thanks
Ding

> On Tue, Aug 9, 2016 at 11:09 AM, Jörn Engel <joern@purestorage.com> wrote:
>> Hello Tianhong!
>>
>> On Tue, Aug 09, 2016 at 10:18:41AM +0800, Ding Tianhong wrote:
>>>
>>> I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
>>> and we will try to fix it.
>>
>> Here is a trivial testcase:
>> openvpn --mktun --dev tun0
>> echo +tun0 > /sys/class/net/bond0/bonding/slaves
>>
>> Worked fine before your patch, no longer works after your patch.  Works
>> again after my patch.
>>
>>> and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
>>> could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.
>>
>> Using bonding in balance-rr mode, there doesn't seem to be a need to
>> change the mac address.  I suppose you might care in other modes, but I
>> don't.
>>
>> Jörn
>>
>> --
>> Time? What's that? Time is only worth what you do with it.
>> -- Theo de Raadt
> 
> .
> 
