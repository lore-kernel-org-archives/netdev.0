From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal tables
Date: Thu, 17 Mar 2016 13:56:32 -0700
Message-ID: <7D6EF4C8-566C-45C9-8B03-55A5CA5D98CB@gmail.com>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com> <20150818181930.GK4381@lunn.ch> <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com> <20150818.134720.1520233036019988872.davem@davemloft.net> <56EB0F37.9090908@ti.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, jiri@resnulli.us
To: Murali Karicheri <m-karicheri2@ti.com>,
	David Miller <davem@davemloft.net>, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33715 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030437AbcCQU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 16:56:45 -0400
Received: by mail-pf0-f170.google.com with SMTP id 4so5056477pfd.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 13:56:45 -0700 (PDT)
In-Reply-To: <56EB0F37.9090908@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 17, 2016 1:10:31 PM PDT, Murali Karicheri <m-karicheri2@ti.com> wrote:
>David,
>
>On 08/18/2015 04:47 PM, David Miller wrote:
>> I see some drivers where the foo_debugfs.c file is larger than the
>rest
>> of the driver.  Once people start using it, it's like crack, and they
>> dump every single debugging widget they found useful at some point
>into
>> there.
>> 
>> This is not what we want.  Most things I see in debugfs support was
>> probably useful for debugging one particular bug but then it was
>never
>> really useful again in the future.  Those kinds of things can be done
>> locally in someone's tree.
>> 
>> I often see various kinds of "statistics" ending up in these things,
>> or register dumps, both of which are 'ethtool' or similar material.
>Very late to this discussion, but I need to port some of the internal
>code
>to display the content of a ALE (Address Learning Engine) table
>maintained
>in hardwareat L2 layer. Currently I have a sysfs implementation that
>dumps
>information like below.
>
>root@k2e-evm:~# cat /sys/devices/platform/soc/2620110.netcp/ale_table
>index 0, raw: 000007fc d000ffff ffffffff, type: addr(1), addr:
>ff:ff:ff:ff:ff:ff, mcstate: f(3), port mask: 1ff, no super
>index 1, raw: 00000000 10000800 28329a1c, type: addr(1), addr:
>08:00:28:32:9a:1c, uctype: persistent(0), port: 0
>index 2, raw: 000007fc d0000100 5e000001, type: addr(1), addr:
>01:00:5e:00:00:01, mcstate: f(3), port mask: 1ff, no super
>index 19, raw: 00000004 d000d4be d93db6c1, type: addr(1), addr:
>d4:be:d9:3d:b6:c1, uctype: touched(3), port: 1
>
>What is the available interface in kernel to expose this information
>to user space as debugfs is not suggested based on this thread

Using something like bridge fdb show (bridge sub command part of iproute2) would give you most of what you need here, except the port mask (since that is semi implied by which interface you use for dumping) and internal flags about the address validity.

How frequently is this code used once you have a proper switch driver which supports the FDB add/del/dump operations?


-- 
Florian
