From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH 01/12] Make and configuration files.
Date: Wed, 28 Dec 2016 06:47:11 +0200
Message-ID: <CAKoUArnT72fQm0fd9JPu7kOjuYPhpTC57+2pswnX-Bvb_XSmgA@mail.gmail.com>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844556.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32963 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbcL1Eyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 23:54:46 -0500
Received: by mail-it0-f66.google.com with SMTP id c20so35070379itb.0
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2016 20:54:46 -0800 (PST)
In-Reply-To: <9cc1565a3a398b4f70248ca98d12991071142682.1482844556.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David,

For the Makefile, you should follow the pattern which is common in
Linux Kernel Ethernet drivers, for example,
http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/i40e/Makefile or
http://lxr.free-electrons.com/source/drivers/net/ethernet/mellanox/mlx5/core/Makefile


Don't think that I ever saw usage of "-j" in a kernel module Makefile;
apart from it, "-j4" is specific to one platform with a given number
of cores, and of course there can be platforms with many more cores,
for which it is less suitable. You can pass the "-j" when running
"make" from the command line, there is no justification to put it in a
Makefile:

>+all:
>+       $(MAKE) -j4 CC=$(CC) -C $(BUILD_DIR) M=$(PWD) modules
>+
>+dox:   .doxygen
>+       @doxygen $<
>+
>+clean:
>+       $(MAKE) -j4 -C $(BUILD_DIR) M=$(PWD) clean

Don't think I ever encountered load/unload targets in Linux Kernel
Makefiles (not talking about out of tree  projects):

>+load:
>+       insmod ./$(TARGET).ko
>+
>+unload:
>+       rmmod ./$(TARGET).ko


Regards,
Rami Rosen
