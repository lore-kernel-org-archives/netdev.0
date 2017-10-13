From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next:master 836/858] bcmsysport.c:undefined reference to
 `unregister_dsa_notifier'
Date: Fri, 13 Oct 2017 12:19:49 -0700
Message-ID: <bc5755d6-0633-9b06-b186-14e2831cc2a3@gmail.com>
References: <201710131551.04CpSDSV%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        andew@lunn.ch, vivien.didelot@savoirfairelinux.com
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:47097 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJMTTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 15:19:54 -0400
Received: by mail-qk0-f196.google.com with SMTP id k123so6245935qke.3
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 12:19:54 -0700 (PDT)
In-Reply-To: <201710131551.04CpSDSV%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2017 12:41 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   2d0d21c12dfa3851620f1fa9fe2d444538f1fad4
> commit: d156576362c07e954dc36e07b0d7b0733a010f7d [836/858] net: systemport: Establish lower/upper queue mapping
> config: x86_64-randconfig-it0-10131242 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         git checkout d156576362c07e954dc36e07b0d7b0733a010f7d
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_remove':
>>> bcmsysport.c:(.text+0x2020): undefined reference to `unregister_dsa_notifier'
>    drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_probe':
>>> bcmsysport.c:(.text+0x3689): undefined reference to `register_dsa_notifier'
>    bcmsysport.c:(.text+0x38d1): undefined reference to `unregister_dsa_notifier'

Ah this configuration is: CONFIG_SYSTEMPORT=y and CONFIG_NET_DSA=m which
would cause the following link failures.

I will submit a fix shortly after making sure that this won't cause
circular dependencies.

Thanks
-- 
Florian
