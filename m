From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rt2500usb: don't mark register accesses as inline
Date: Wed, 15 Feb 2017 09:16:24 +0000 (UTC)
Message-ID: <20170215091624.6F1AB608EA@smtp.codeaurora.org>
References: <20170214212846.2809141-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Arnd Bergmann <arnd@arndb.de>, Mathias Kresin <dev@kresin.me>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46708 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdBOJQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 04:16:25 -0500
In-Reply-To: <20170214212846.2809141-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:
> When CONFIG_KASAN is set, we get a rather large stack here:
> 
> drivers/net/wireless/ralink/rt2x00/rt2500usb.c: In function 'rt2500usb_set_device_state':
> drivers/net/wireless/ralink/rt2x00/rt2500usb.c:1074:1: error: the frame size of 3032 bytes is larger than 100 bytes [-Werror=frame-larger-than=]
> 
> If we don't force those functions to be inline, the compiler can figure this
> out better itself and not inline the functions when doing so would be harmful,
> reducing the stack size to a merge 256 bytes.
> 
> Note that there is another problem that manifests in this driver, as a result
> of the typecheck() macro causing even larger stack frames.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

727241660912 rt2500usb: don't mark register accesses as inline

-- 
https://patchwork.kernel.org/patch/9572947/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
