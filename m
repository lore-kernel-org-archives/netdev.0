From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Thu, 17 Mar 2016 16:10:31 -0400
Message-ID: <56EB0F37.9090908@ti.com>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
 <20150818181930.GK4381@lunn.ch>
 <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
 <20150818.134720.1520233036019988872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <andrew@lunn.ch>, <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>, <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53510 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbcCQUKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 16:10:46 -0400
In-Reply-To: <20150818.134720.1520233036019988872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On 08/18/2015 04:47 PM, David Miller wrote:
> I see some drivers where the foo_debugfs.c file is larger than the rest
> of the driver.  Once people start using it, it's like crack, and they
> dump every single debugging widget they found useful at some point into
> there.
> 
> This is not what we want.  Most things I see in debugfs support was
> probably useful for debugging one particular bug but then it was never
> really useful again in the future.  Those kinds of things can be done
> locally in someone's tree.
> 
> I often see various kinds of "statistics" ending up in these things,
> or register dumps, both of which are 'ethtool' or similar material.
Very late to this discussion, but I need to port some of the internal code
to display the content of a ALE (Address Learning Engine) table maintained
in hardwareat L2 layer. Currently I have a sysfs implementation that dumps
information like below.

root@k2e-evm:~# cat /sys/devices/platform/soc/2620110.netcp/ale_table
index 0, raw: 000007fc d000ffff ffffffff, type: addr(1), addr: ff:ff:ff:ff:ff:ff, mcstate: f(3), port mask: 1ff, no super
index 1, raw: 00000000 10000800 28329a1c, type: addr(1), addr: 08:00:28:32:9a:1c, uctype: persistent(0), port: 0
index 2, raw: 000007fc d0000100 5e000001, type: addr(1), addr: 01:00:5e:00:00:01, mcstate: f(3), port mask: 1ff, no super
index 19, raw: 00000004 d000d4be d93db6c1, type: addr(1), addr: d4:be:d9:3d:b6:c1, uctype: touched(3), port: 1

What is the available interface in kernel to expose this information
to user space as debugfs is not suggested based on this thread?

-- 
Murali Karicheri
Linux Kernel, Keystone
