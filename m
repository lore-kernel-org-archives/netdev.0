From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Thu, 17 Mar 2016 23:53:14 +0200
Message-ID: <20160317215314.GA4925@colbert.idosch.org>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
 <20150818181930.GK4381@lunn.ch>
 <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
 <20150818.134720.1520233036019988872.davem@davemloft.net>
 <56EB0F37.9090908@ti.com>
 <20160317202519.GA30210@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	David Miller <davem@davemloft.net>, <sfeldma@gmail.com>,
	<netdev@vger.kernel.org>, <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0059.outbound.protection.outlook.com ([157.56.112.59]:7072
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031070AbcCQWJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 18:09:44 -0400
Content-Disposition: inline
In-Reply-To: <20160317202519.GA30210@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 17, 2016 at 10:25:19PM IST, andrew@lunn.ch wrote:
>On Thu, Mar 17, 2016 at 04:10:31PM -0400, Murali Karicheri wrote:
>> David,
>> 
>> On 08/18/2015 04:47 PM, David Miller wrote:
>> > I see some drivers where the foo_debugfs.c file is larger than the rest
>> > of the driver.  Once people start using it, it's like crack, and they
>> > dump every single debugging widget they found useful at some point into
>> > there.
>> > 
>> > This is not what we want.  Most things I see in debugfs support was
>> > probably useful for debugging one particular bug but then it was never
>> > really useful again in the future.  Those kinds of things can be done
>> > locally in someone's tree.
>> > 
>> > I often see various kinds of "statistics" ending up in these things,
>> > or register dumps, both of which are 'ethtool' or similar material.
>> Very late to this discussion, but I need to port some of the internal code
>> to display the content of a ALE (Address Learning Engine) table maintained
>> in hardwareat L2 layer. Currently I have a sysfs implementation that dumps
>> information like below.
>> 
>> root@k2e-evm:~# cat /sys/devices/platform/soc/2620110.netcp/ale_table
>> index 0, raw: 000007fc d000ffff ffffffff, type: addr(1), addr: ff:ff:ff:ff:ff:ff, mcstate: f(3), port mask: 1ff, no super
>> index 1, raw: 00000000 10000800 28329a1c, type: addr(1), addr: 08:00:28:32:9a:1c, uctype: persistent(0), port: 0
>> index 2, raw: 000007fc d0000100 5e000001, type: addr(1), addr: 01:00:5e:00:00:01, mcstate: f(3), port mask: 1ff, no super
>> index 19, raw: 00000004 d000d4be d93db6c1, type: addr(1), addr: d4:be:d9:3d:b6:c1, uctype: touched(3), port: 1
>> 
>> What is the available interface in kernel to expose this information
>> to user space as debugfs is not suggested based on this thread?
>
>This looks a lot like what the mv88e6xxx_port_fdb_dump() callback
>returns to DSA when SWITCHDEV_OBJ_ID_PORT_FDB is passed to
>switchdev_port_obj_dump() in the switchdev ops.

+1

Also, Murali, using standard interfaces instead of debugfs will allow
you to:

1) Upstream your code
2) Use existing tests for your code. In particular, the following
(which is used for mlxsw testing):

https://github.com/jpirko/lnst/blob/master/recipes/switchdev/l2-002-bridge_fdb.py

There are a bunch of others there which you'll probably find useful.

BTW, are you familiar with the following document?
https://www.kernel.org/doc/Documentation/networking/switchdev.txt
I believe it answers your question.

Good luck!

>
>	  Andrew
