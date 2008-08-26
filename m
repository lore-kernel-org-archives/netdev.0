From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/6] [RFC] qlge: New Driver: Adding driver header file qlge.h.
Date: Tue, 26 Aug 2008 12:00:54 +0100
Message-ID: <20080826110053.GX7908@solarflare.com>
References: <20080822200906.GD2551@susedev.qlogic.org> <12194364663882-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:48361 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758034AbYHZLA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:00:58 -0400
Content-Disposition: inline
In-Reply-To: <12194364663882-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge.h | 1602 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 1602 insertions(+), 0 deletions(-)
>  create mode 100755 drivers/net/qlge/qlge.h
> 
> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
> new file mode 100755
> index 0000000..11a07fd
> --- /dev/null
> +++ b/drivers/net/qlge/qlge.h
[...]
> +#define PFX "qlge: "
> +#define QPRINTK(nlevel, klevel, fmt, args...) \
> +	((void)((NETIF_MSG_##nlevel & qdev->msg_enable) && \
> +	printk(KERN_##klevel PFX "%s: %s: " fmt, qdev->ndev->name, \
> +		__FUNCTION__ , ## args)))

Macros that refer to local variables are nasty.  qdev should be a macro
parameter.  __FUNCTION__ (gcc extension) should be replaced with __func__
(C99).  Finally, this should call dev_printk() - something like this:

#define QPRINTK(qdev, nlevel, klevel, fmt, args...)		\
	if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))		\
		;						\
	else							\
		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
			   "%s: " fmt, __func__, ##args)

> +/*
> + * IOCB Definitions...
> + */
> +#pragma pack(1)
[...]

Ew, no.  You should use __packed at the end of each structure definition.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
