From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH 01/12] Make and configuration files.
Date: Tue, 27 Dec 2016 21:24:35 -0800
Message-ID: <01df94bb-6f31-1fea-50a2-3f0136b969cc@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844556.git.vomlehn@texas.net>
 <CAKoUArnT72fQm0fd9JPu7kOjuYPhpTC57+2pswnX-Bvb_XSmgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda3.aus1.datafoundry.com ([209.99.124.134]:36608 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750744AbcL1FZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 00:25:58 -0500
In-Reply-To: <CAKoUArnT72fQm0fd9JPu7kOjuYPhpTC57+2pswnX-Bvb_XSmgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2016 08:47 PM, Rami Rosen wrote:
> Hi, David,
>
> For the Makefile, you should follow the pattern which is common in
> Linux Kernel Ethernet drivers, for example,
> http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/i40e/Makefile or
> http://lxr.free-electrons.com/source/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>
>
> Don't think that I ever saw usage of "-j" in a kernel module Makefile;
> apart from it, "-j4" is specific to one platform with a given number
> of cores, and of course there can be platforms with many more cores,
> for which it is less suitable. You can pass the "-j" when running
> "make" from the command line, there is no justification to put it in a
> Makefile:
>
>> +all:
>> +       $(MAKE) -j4 CC=$(CC) -C $(BUILD_DIR) M=$(PWD) modules
>> +
>> +dox:   .doxygen
>> +       @doxygen $<
>> +
>> +clean:
>> +       $(MAKE) -j4 -C $(BUILD_DIR) M=$(PWD) clean
> Don't think I ever encountered load/unload targets in Linux Kernel
> Makefiles (not talking about out of tree  projects):
>
>> +load:
>> +       insmod ./$(TARGET).ko
>> +
>> +unload:
>> +       rmmod ./$(TARGET).ko
>
> Regards,
> Rami Rosen
You are right. The driver spent a while as an out-of-tree build module, 
where this made sense. It clearly no longer makes sense.


-- 
David VL
