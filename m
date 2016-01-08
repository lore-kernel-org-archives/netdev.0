From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4.4-rc8 5/7] isdn: eicon: divasfunc: Silence frame size
 warning
Date: Fri, 8 Jan 2016 23:05:19 +0300
Message-ID: <5690167F.6030405@cogentembedded.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
 <1452256375-24223-6-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: tim.gardner@canonical.com, Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35010 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbcAHUFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 15:05:22 -0500
Received: by mail-lb0-f175.google.com with SMTP id bc4so229651330lbc.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 12:05:21 -0800 (PST)
In-Reply-To: <1452256375-24223-6-git-send-email-tim.gardner@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2016 03:32 PM, tim.gardner@canonical.com wrote:

> From: Tim Gardner <tim.gardner@canonical.com>
>
> drivers/isdn/hardware/eicon/divasfunc.c: In function 'connect_didd':
> drivers/isdn/hardware/eicon/divasfunc.c:192:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>
> gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)
>
> Cc: Armin Schindler <mac@melware.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
>   drivers/isdn/hardware/eicon/divasfunc.c | 12 +++++++++---
>   1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/hardware/eicon/divasfunc.c
> index 4be5f88..ac4c04a 100644
> --- a/drivers/isdn/hardware/eicon/divasfunc.c
> +++ b/drivers/isdn/hardware/eicon/divasfunc.c
> @@ -158,10 +158,13 @@ static int __init connect_didd(void)
>   	int x = 0;
>   	int dadapter = 0;
>   	IDI_SYNC_REQ req;
> -	DESCRIPTOR DIDD_Table[MAX_DESCRIPTORS];
> +	DESCRIPTOR *DIDD_Table;
>
> -	DIVA_DIDD_Read(DIDD_Table, sizeof(DIDD_Table));
> +	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);

    kmalloc_array()?

MBR, Sergei
