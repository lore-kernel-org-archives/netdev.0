From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] rocker: fix harmless warning on 32-bit machines
Date: Tue, 13 Jan 2015 15:36:35 +0100
Message-ID: <20150113143635.GB1839@nanopsycho.lan>
References: <4047824.AYNhYQQ6UI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:40257 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbAMOgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 09:36:38 -0500
Received: by mail-we0-f181.google.com with SMTP id q58so3252058wes.12
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 06:36:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4047824.AYNhYQQ6UI@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 13, 2015 at 03:23:52PM CET, arnd@arndb.de wrote:
>The rocker driver tries to assign a pointer to a 64-bit integer
>and then back to a pointer. This is safe on all architectures,
>but causes a compiler warning when pointers are shorter than
>64-bit:
>
>rocker/rocker.c: In function 'rocker_desc_cookie_ptr_get':
>rocker/rocker.c:809:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>  return (void *) desc_info->desc->cookie;
>         ^
>
>This adds another cast to uintptr_t to tell the compiler
>that it's safe.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>


Acked-by: Jiri Pirko <jiri@resnulli.us>

>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 2f398fa4b9e6..cad8cf962cdf 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -806,13 +806,13 @@ static bool rocker_desc_gen(struct rocker_desc_info *desc_info)
> 
> static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
> {
>-	return (void *) desc_info->desc->cookie;
>+	return (void *)(uintptr_t)desc_info->desc->cookie;
> }
> 
> static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
> 				       void *ptr)
> {
>-	desc_info->desc->cookie = (long) ptr;
>+	desc_info->desc->cookie = (uintptr_t) ptr;
> }
> 
> static struct rocker_desc_info *
>
