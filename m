From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [linux-next:master 1436/1582] drivers/net/ethernet/smsc/smc91x.c:2378:6: error: implicit declaration of function 'machine_is_assabet'
Date: Wed, 19 Oct 2016 21:58:06 +0200
Message-ID: <87funs3ycx.fsf@belgarion.home>
References: <201610200342.Wv4wShnU%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:50920 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755798AbcJST6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 15:58:11 -0400
In-Reply-To: <201610200342.Wv4wShnU%fengguang.wu@intel.com> (kbuild test
        robot's message of "Thu, 20 Oct 2016 03:31:48 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here is a little mess I created with my former serie :
>    drivers/net/ethernet/smsc/smc91x.c: In function 'smc_drv_probe':
>>> drivers/net/ethernet/smsc/smc91x.c:2378:6: error: implicit declaration of function 'machine_is_assabet' [-Werror=implicit-function-declaration]
>      if (machine_is_assabet() && machine_has_neponset())
>          ^~~~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors
>
> vim +/machine_is_assabet +2378 drivers/net/ethernet/smsc/smc91x.c

The mess comes from the patch "net: smc91x: isolate u16 writes alignment
workaround", where I though I had removed all "machine_is_*()" calls, and I
didn't notice the machine_is_assabet() one.

The fix is to re-add the removed include in the wrong chunk in [1].

Now do you want :
 - another apart patch to fix the faulty one
 - a "fixup!" patch to fixup the commit in your next tree
 - or anything else

As I didn't compile assabet, my testers have missed this one. Please tell me
which way suits you to repair this commit.

Cheers.
