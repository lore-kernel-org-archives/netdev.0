From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH net-next] brcmfmac: fix build without CONFIG_BRCMFMAC_PROTO_BCDC
Date: Thu, 20 Apr 2017 07:34:31 +0300
Message-ID: <874lxj7l48.fsf@codeaurora.org>
References: <20170419221133.2180685-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44028 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940988AbdDTEe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 00:34:56 -0400
In-Reply-To: <20170419221133.2180685-1-arnd@arndb.de> (Arnd Bergmann's message
        of "Thu, 20 Apr 2017 00:10:24 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> With CONFIG_BRCMFMAC_PROTO_BCDC unset, we cannot build the fwsignal.c file:
>
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c: In function 'brcmf_fws_notify_credit_map':
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c:1590:31: error: implicit declaration of function 'drvr_to_fws'; did you mean 'dev_to_psd'? [-Werror=implicit-function-declaration]
>   struct brcmf_fws_info *fws = drvr_to_fws(ifp->drvr);
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c:1590:31: error: initialization makes pointer from integer without a cast [-Werror=int-conversion]
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c:1621:31: error: initialization makes pointer from integer without a cast [-Werror=int-conversion]
>
> However, as pointed out in the changeset description for the patch that caused
> the problem, fwsignal.c is only required when CONFIG_BRCMFMAC_PROTO_BCDC is
> enabled, so we can simply change the Makefile to build it conditionally.
>
> Fixes: acf8ac41dd73 ("brcmfmac: remove reference to fwsignal data from struct brcmf_pub")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

The fix is actually for wireless-drivers-next, acf8ac41dd73 is not in
net-next yet. And I already applied an identical fix from Arend:

https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=26ecfe01790381c4caa65ec9cce484c623f092c4

-- 
Kalle Valo
