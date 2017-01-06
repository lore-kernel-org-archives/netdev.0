From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/12] net: ethernet: aquantia: Add AQtion 2.5/5 GB
 NIC driver
Date: Fri, 06 Jan 2017 16:02:06 -0500 (EST)
Message-ID: <20170106.160206.1149383357421277805.davem@davemloft.net>
References: <cover.1483689029.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vomlehn@texas.net,
        Simon.Edelhaus@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Pavel.Belous@aquantia.com
To: Alexander.Loktionov@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdAFVJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:09:25 -0500
In-Reply-To: <cover.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Date: Fri,  6 Jan 2017 00:06:01 -0800

> This series introduced the AQtion NIC driver for the aQuantia
> AQC107/AQC108 network devices.
> 
> v1: Initial version
> v2: o Make necessary drivers/net/ethernet changes to integrate software
>     o Drop intermediate atlantic directory
>     o Remove Makefile things only appropriate to out of tree module builidng

Every patch series must be fully bisectable, this means that at each step
of the series, the kernel tree must fully build and work properly.

You break that already at the first patch, which makes the Kconfig options
available, which if enabled will cause a build failure.

make[4]: *** No rule to make target 'drivers/net/ethernet/aquantia/aq_main.o', needed by 'drivers/net/ethernet/aquantia/atlantic.o'.  Stop.
make[4]: *** Waiting for unfinished jobs....
scripts/Makefile.build:551: recipe for target 'drivers/net/ethernet/aquantia' failed
make[3]: *** [drivers/net/ethernet/aquantia] Error 2
make[3]: *** Waiting for unfinished jobs....
scripts/Makefile.build:551: recipe for target 'drivers/net/ethernet' failed
make[2]: *** [drivers/net/ethernet] Error 2
scripts/Makefile.build:551: recipe for target 'drivers/net' failed
make[1]: *** [drivers/net] Error 2
make[1]: *** Waiting for unfinished jobs....
Makefile:988: recipe for target 'drivers' failed
make: *** [drivers] Error 2

The way to do this, is to add the pieces of source code infrastrucutre,
one piece at a time.  And then at the very very end, enable the code
into the build.
