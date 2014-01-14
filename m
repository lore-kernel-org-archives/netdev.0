From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net 0/2] bonding: fix the sysfs warning when change the
 master's name
Date: Tue, 14 Jan 2014 09:49:03 +0800
Message-ID: <52D4978F.4090104@huawei.com>
References: <52D3E536.8080404@huawei.com> <20140113172446.GA2081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:49002 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbaANBtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:49:24 -0500
In-Reply-To: <20140113172446.GA2081@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 1:24, Veaceslav Falico wrote:
> On Mon, Jan 13, 2014 at 09:08:06PM +0800, Ding Tianhong wrote:
>> When I change the master's name, and then rebuild the master and ensalve a nic again,
>> than I got the calltrace:
>>
>> [329215.749344] WARNING: CPU: 0 PID: 4778 at fs/sysfs/dir.c:486 sysfs_warn_dup+0x87/0xa0()
>> [329215.749347] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:03.0/0000:02:00.0/net/eth100/upper_bond0'
> ...snip...
>> [329215.749494]  [<ffffffff81205b27>] sysfs_warn_dup+0x87/0xa0
>> [329215.749500]  [<ffffffff81205eed>] sysfs_add_one+0x4d/0x50
>> [329215.749505]  [<ffffffff81206f9e>] sysfs_do_create_link_sd+0xbe/0x210
>> [329215.749511]  [<ffffffff812951a0>] ? sprintf+0x40/0x50
>> [329215.749516]  [<ffffffff8120714b>] sysfs_create_link+0x2b/0x30
>> [329215.749523]  [<ffffffff8140a708>] __netdev_adjacent_dev_insert+0x1b8/0x270
>> [329215.749528]  [<ffffffff8140a7f8>] __netdev_adjacent_dev_link_lists+0x38/0x90
>> [329215.749533]  [<ffffffff8140a98b>] __netdev_upper_dev_link+0x13b/0x470
>> [329215.749538]  [<ffffffff8141319c>] ? __ethtool_get_settings+0x5c/0x90
>> [329215.749547]  [<ffffffffa0722179>] ? bond_update_speed_duplex+0x29/0x70 [bonding]
>> [329215.749552]  [<ffffffff8140acd1>] netdev_master_upper_dev_link_private+0x11/0x20
>> [329215.749561]  [<ffffffffa0729246>] bond_enslave+0x806/0xe40 [bonding]
>> [329215.749570]  [<ffffffffa073241f>] bonding_store_slaves+0x18f/0x1c0 [bonding]
>> [329215.749576]  [<ffffffff813757ab>] dev_attr_store+0x1b/0x20
>> [329215.749581]  [<ffffffff812049cc>] sysfs_write_file+0x15c/0x1f0
>> [329215.749587]  [<ffffffff81188897>] vfs_write+0xc7/0x1e0
> 
> It's unrelated to bonding, as it touches any device that uses netdev_adjacent
> logic.

Yes, it is a problem for every device that uses netdev_adjacent.
> 
> This case (renaming stale sysfs links) should be properly handled in
> dev_change_name().
> 

Ok, I will try and fix it in dev_change_name().

> .
> 
