From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rocker: fix harmless warning on 32-bit machines
Date: Tue, 13 Jan 2015 16:56:57 -0500 (EST)
Message-ID: <20150113.165657.1171408376100942920.davem@davemloft.net>
References: <4047824.AYNhYQQ6UI@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbbAMV5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:57:00 -0500
In-Reply-To: <4047824.AYNhYQQ6UI@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 13 Jan 2015 15:23:52 +0100

> The rocker driver tries to assign a pointer to a 64-bit integer
> and then back to a pointer. This is safe on all architectures,
> but causes a compiler warning when pointers are shorter than
> 64-bit:
> 
> rocker/rocker.c: In function 'rocker_desc_cookie_ptr_get':
> rocker/rocker.c:809:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>   return (void *) desc_info->desc->cookie;
>          ^
> 
> This adds another cast to uintptr_t to tell the compiler
> that it's safe.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next, thanks.
