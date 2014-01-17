From: chenweilong <chenweilong@huawei.com>
Subject: Re: [PATCH] net: fix "queues" uevent between network namespaces
Date: Fri, 17 Jan 2014 09:47:15 +0800
Message-ID: <52D88BA3.5010201@huawei.com>
References: <1389864271-24212-1-git-send-email-chenweilong@huawei.com> <20140116161912.GB7476@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:64535 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaAQBrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:47:52 -0500
In-Reply-To: <20140116161912.GB7476@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/17 0:19, Greg KH wrote:
> On Thu, Jan 16, 2014 at 05:24:31PM +0800, Chen Weilong wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
>>
>> When I create a new namespace with 'ip netns add net0', or add/remove
>> new links in a namespace with 'ip link add/delete type veth', rx/tx
>> queues events can be got in all namespaces. That is because rx/tx queue
>> ktypes do not have namespace support, and their kobj parents are setted to
>> NULL. This patch is to fix it.
>>
>> Reported-by: Libo Chen <chenlibo@huawei.com>
>> Signed-off-by: Libo Chen <chenlibo@huawei.com>
>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>> ---
>>  lib/kobject_uevent.c | 10 ++++++++--
>>  net/core/net-sysfs.c | 26 ++++++++++++++++++++++++++
>>  2 files changed, 34 insertions(+), 2 deletions(-)
> 
> I can't test this, but it looks good to me:
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> 

Hi,

Here's detail about the test, I hope it can be useful:
step1: create two netns
	suse11-sp3:~ # ip netns add net0
	suse11-sp3:~ # ip netns add net1
	suse11-sp3:~ # ip netns list
	net1
	net0
setp2: monitor udev events
	Term1:
	suse11-sp3:~ # ip netns exec net0 udevadm monitor
	Term2:
	suse11-sp3:~ # ip netns exec net1 udevadm monitor
setp3: add link to net0
	suse11-sp3:~ # ip netns exec net0 ip link add type veth

Then you'll see the below events in net0 and net1.
KERNEL[1389972662.984988] add      /devices/virtual/net/veth0/queues/rx-0 (queues)
KERNEL[1389972662.985008] add      /devices/virtual/net/veth0/queues/tx-0 (queues)
KERNEL[1389972662.985234] add      /devices/virtual/net/veth1/queues/rx-0 (queues)
KERNEL[1389972662.985247] add      /devices/virtual/net/veth1/queues/tx-0 (queues)
