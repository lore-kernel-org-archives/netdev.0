From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] s2io: fixing DBG_PRINT() macro
Date: Fri, 05 Mar 2010 11:21:06 -0300
Message-ID: <4B911352.2000407@linux.vnet.ibm.com>
References: <1267623697-14781-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: sreenivasa.honnur@neterion.com, joe@perches.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:53636 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab0CEOVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 09:21:14 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.3/8.13.1) with ESMTP id o25EZnUS010736
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 11:35:49 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o25EO5uZ1044984
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 11:24:07 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o25EL7xj002735
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 11:21:08 -0300
In-Reply-To: <1267623697-14781-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, 

Due my mistake I didn't send this patch to Sreenivasa. After
sending this patch to netdev, I forward to him, and
he acked it privately.

Sorry for the confusion. 
Thanks, 
Breno

leitao@linux.vnet.ibm.com wrote:
> Patch 9e39f7c5b311a306977c5471f9e2ce4c456aa038 changed the
> DBG_PRINT() macro and the if clause was changed. It means
> that currently all the DBG_PRINT are being printed, flooding
> the kernel log buffer with thinkgs like:
> 
> s2io: eth6: Next block at: c0000000b9c90000
> s2io: eth6: In Neterion Tx routine
> 
> This patch just fixes the if clause condition.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> ---
>  drivers/net/s2io.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 47c36e0..3b6f45d 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -65,7 +65,7 @@ static int debug_level = ERR_DBG;
> 
>  /* DEBUG message print. */
>  #define DBG_PRINT(dbg_level, fmt, args...) do {			\
> -	if (dbg_level >= debug_level)				\
> +	if (dbg_level <= debug_level)				\
>  		pr_info(fmt, ##args);				\
>  	} while (0)
> 
