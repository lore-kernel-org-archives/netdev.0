From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC
 driver
Date: Fri, 13 Jan 2017 18:05:42 -0800
Message-ID: <586c76ba-2bae-0b48-76b4-042699659533@gmail.com>
References: <cover.1484283610.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33548 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdANCFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 21:05:45 -0500
Received: by mail-it0-f66.google.com with SMTP id v14so6896436itb.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 18:05:44 -0800 (PST)
In-Reply-To: <cover.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> v1: Initial version
> v2: o Make necessary drivers/net/ethernet changes to integrate software
>     o Drop intermediate atlantic directory
>     o Remove Makefile things only appropriate to out of tree module
>       building
> v3: o Move changes to drivers/net/ethernet/{Kconfig,Makefile} to the last
>       patch to ensure clean bisection.
>     o Removed inline attribute aq_hw_write_req() as it was defined in
>       only one .c file.
>     o #included pci.h in aq_common.h to get struct pci definition.
>     o Modified code to unlock based execution flow rather than using a
>       flag.
>     o Made a number of functions that were only used in a single file
>       static.
>     o Cleaned up error and return code handling in various places.
>     o Remove AQ_CFG_IP_ALIGN definition.
>     o Other minor code clean up.
> v4: o Using do_div for 64 bit division.
>     o Modified NIC statistics code.
>     o Using build_skb instead netdev_alloc_skb for single fragment
>       packets.
>     o Removed extra aq_nic.o from Makefile
> v5: o Removed extra newline at the end of the files.
>     o Wrapped cover letter lines.

Few build warnings with W=1 (W=2 is just too verbose) that you may want
to fix, this was with GCC 4.8, newer compilers may flag new warnings as
well:

drivers/net/ethernet/aquantia/aq_main.c: In function
'aq_pci_probe_get_hw_ops_by_id':
drivers/net/ethernet/aquantia/aq_main.c:41:6: warning: variable 'err'
set but not used [-Wunused-but-set-variable]
  int err = 0;
      ^
drivers/net/ethernet/aquantia/aq_main.c: In function 'aq_pci_remove':
drivers/net/ethernet/aquantia/aq_main.c:237:6: warning: variable 'err'
set but not used [-Wunused-but-set-variable]
  int err = 0;
      ^

-- 
Florian
