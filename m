From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4.4-rc8 6/7] isdn: eicon: diddfunc: Silence frame size
 warning
Date: Fri, 8 Jan 2016 23:04:11 +0300
Message-ID: <5690163B.7050808@cogentembedded.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
 <1452256375-24223-7-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: tim.gardner@canonical.com, Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34632 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbcAHUEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 15:04:15 -0500
Received: by mail-lf0-f41.google.com with SMTP id d17so15858501lfb.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 12:04:15 -0800 (PST)
In-Reply-To: <1452256375-24223-7-git-send-email-tim.gardner@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/08/2016 03:32 PM, tim.gardner@canonical.com wrote:

> From: Tim Gardner <tim.gardner@canonical.com>
>
> drivers/isdn/hardware/eicon/diddfunc.c: In function 'connect_didd':
> drivers/isdn/hardware/eicon/diddfunc.c:77:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>
> gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)
>
> Cc: Armin Schindler <mac@melware.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
>   drivers/isdn/hardware/eicon/diddfunc.c | 17 +++++++++++++----
>   1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/isdn/hardware/eicon/diddfunc.c b/drivers/isdn/hardware/eicon/diddfunc.c
> index b0b23ed..a9feb4f 100644
> --- a/drivers/isdn/hardware/eicon/diddfunc.c
> +++ b/drivers/isdn/hardware/eicon/diddfunc.c
> @@ -52,9 +52,13 @@ static int __init connect_didd(void)
>   	int x = 0;
>   	int dadapter = 0;
>   	IDI_SYNC_REQ req;
> -	DESCRIPTOR DIDD_Table[MAX_DESCRIPTORS];
> +	DESCRIPTOR *DIDD_Table;
>
> -	DIVA_DIDD_Read(DIDD_Table, sizeof(DIDD_Table));
> +	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);

   Previously the array didn't seem to be zeroed, perhaps it's better to use 
kmalloc_array()?

[...]

MHR, Sergei
