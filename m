From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 122/152] drivers/ptp/ptp_chardev.c:36
 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
Date: Fri, 02 Nov 2012 21:39:28 -0400 (EDT)
Message-ID: <20121102.213928.934210347094361569.davem@davemloft.net>
References: <509326ff.Rs30l/1GTlOl9dW+%yuanhan.liu@linux.intel.com>
	<20121102020631.GI16883@yliu-dev.sh.intel.com>
	<20121102085915.GC2486@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuanhan.liu@linux.intel.com, changlongx.xie@intel.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2KCBja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:39:30 -0400
In-Reply-To: <20121102085915.GC2486@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 2 Nov 2012 09:59:15 +0100

> On Fri, Nov 02, 2012 at 10:06:31AM +0800, Yuanhan Liu wrote:
>> 
>> Hi Richard,
>> 
>> _just_ FYI and let you aware of it, there are new smatch warnings show up in
>> 
>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>> head:   b77bc2069d1e437d5a1a71bb5cfcf4556ee40015
>> commit: 215b13dd288c2e1e4461c1530a801f5f83e8cd90 [122/152] ptp: add an ioctl to compare PHC time with system time
>> 
>> + drivers/ptp/ptp_chardev.c:36 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
>>   drivers/ptp/ptp_chardev.c:144 ptp_read() warn: 'event' puts 960 bytes on stack
> 
> I am aware that these methods use large stack buffers, but I thought
> it was okay seeing as they are both under the 1k limit.

I think you should avoid such a local stack variable here.

It's not that big of a deal to use kmalloc or whatever so just
do that and add the necessary kfree cleanups et al.
