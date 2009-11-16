From: zeal <zealcook@gmail.com>
Subject: KS8695: problem with ethernet driver
Date: Mon, 16 Nov 2009 17:23:32 +0800
Message-ID: <efc9214f0911160123t31d7df31tc1afcbd5129b7d86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Figo.zhang" <figo1802@gmail.com>,
	Vincent Sanders <vince@simtec.co.uk>,
	Ben Dooks <ben@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:39979 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbZKPJX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:23:29 -0500
Received: by yxe17 with SMTP id 17so4539926yxe.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:23:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've two questions on the ks8695.

1. We knew recently Figo.zhang has added NAPI support for ks8695 net driver.
Thanks him. But on our ks8695 board it couldn't work well as i thought.
We used net-next-git kernel.

IP layer cannot receive any frame from lan or wan port(s).

After dig into the driver, I found the rx interrupt occurs,
but the corresponding status bit is not set. So it won't go into napi
schedule block.

        if (status & mask_bit) {
                if (napi_schedule_prep(&ksp->napi)) {
                        /*disable rx interrupt*/
                        status &= ~mask_bit;
                        writel(status , KS8695_IRQ_VA + KS8695_INTEN);
                        __napi_schedule(&ksp->napi);
                }
        }

Does anybody tested this NAPI driver succeeded before? If so it maybe
hardware issue.

2. It's a extend topic about ks8695. Does the cpu port can tell the
source port (i.e. lan port ID)
when it receive a frame from LAN ports? I think a smart switch need
know where the frame come from
and then decide where it to go. And many switch-chip in this way.
The manual can't help me at all as i've done according to it.

Any hint is appreciated.

-- 
Thanks & Regards

zeal
