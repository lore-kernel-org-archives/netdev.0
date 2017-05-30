From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] cxgb4: FW upgrade fixes
Date: Tue, 30 May 2017 12:39:45 +0300
Message-ID: <3970fd69-a6fd-c0ba-6bf0-31fb3f54f1c1@cogentembedded.com>
References: <1496128525-7881-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nirranjan@chelsio.com, Arjun Vynipadath <arjun@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>
To: Ganesh Goudar <ganeshgr@chelsio.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33815 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdE3Jjr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 05:39:47 -0400
Received: by mail-lf0-f47.google.com with SMTP id 99so45950286lfu.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 02:39:46 -0700 (PDT)
In-Reply-To: <1496128525-7881-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 5/30/2017 10:15 AM, Ganesh Goudar wrote:

> From: Arjun Vynipadath <arjun@chelsio.com>
>
> Disable FW_OK flags while flashing Firmware. This will help to fix any
> potential mailbox timeouts during Firmware flash.
>
> Grab new devlog parameters after Firmware restart. When we FLASH new
> Firmware onto an adapter, the new Firmware may have the Firmware Device Log
> located at a different memory address or have a different size for it.
>
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index b97ce4a..325f98c 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -6288,13 +6288,18 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
>  	if (!t4_fw_matches_chip(adap, fw_hdr))
>  		return -EINVAL;
>
> +	/* Disable FW_OK flags so that mbox commands with FW_OK flags check
> +	 * wont be send when we are flashing FW.

    Sent.

[...]

MBR, Sergei
