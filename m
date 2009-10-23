From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: PATCH 23/10]Optimize the upload speed for PPP connection.
Date: Fri, 23 Oct 2009 07:46:08 -0400
Message-ID: <4AE19780.3020507@gmail.com>
References: <fae097f21b27.1b27fae097f2@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	zihan@huawei.com, greg@kroah.com, haegar@sdinet.de
To: fangxiaozhi 00110321 <huananhu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:41791 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbZJWLqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 07:46:08 -0400
In-Reply-To: <fae097f21b27.1b27fae097f2@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fangxiaozhi 00110321 wrote:
> From: fangxiaozhi <huananhu@huawei.com>
> 1. This patch is based on the kernel of 2.6.32-rc4 
> 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
> Signed-off-by: fangxiaozhi <huananhu@huawei.com>
> -----------------------------------------------------------------------------------------
> --- a/drivers/net/ppp_async.c	2009-10-12 05:43:56.000000000 +0800
> +++ b/drivers/net/ppp_async.c	2009-10-15 16:29:56.000000000 +0800
> @@ -36,7 +36,7 @@
>  
>  #define PPP_VERSION	"2.4.2"
>  
> -#define OBUFSIZE	256
> +#define OBUFSIZE	2048
>  
>  /* Structure for storing local state. */
>  struct asyncppp {
> 
Concur.  I'd go further than that, my code usually made room for at least
a full MTU (MRU) with HDLC escaping.  To minimize context switches, that
should be 3014 ((1500 MRU + 2 FCS + 4 header) * 2 escapes + 2 flags).

Even in the old days, when memory was tight, context switches and interrupt
time were more expensive, too.  PPP is supposed to scale to OC-192.
