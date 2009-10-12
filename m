From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 5/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 14:51:08 +0200
Message-ID: <4AD3263C.9010605@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout084B.attiva.biz ([85.33.31.84]:4270 "EHLO
	smtpout084B.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771AbZJLMwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 08:52:07 -0400
In-Reply-To: <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Hi Sjur,

> diff --git a/net/caif/caif_chr.c b/net/caif/caif_chr.c

> +#define caif_assert(assert) BUG_ON(!(assert))

Do we need special assert for each module (cfglu_assert,
caif_assert,...) ? They are all defined in the same way.
At this point I have already set a comment about using BUG_ON in a
previous patch.

I see a mixed policy in this patch, using sometimes _assert and
sometimes directly BUG_ON, too.

> diff --git a/net/caif/chnl_chr.c b/net/caif/chnl_chr.c

> +	/* Lock in order to try to stop someone from opening the device
> +	   too early. The misc device has its own lock. We cannot take our
> +	   lock until misc_register() is finished, because in open() the
> +	   locks are taken in this order (misc first and then dev).
> +	   So anyone managing to open the device between the misc_register
> +	   and the mutex_lock will get a "device not found" error. Don't
> +	   think it can be avoided.
> +	 */
> +	mutex_lock_interruptible(&dev->mutex);

The return value is not checked and it must be, as in all other cases.

> +	/* Find device from name */
> +	dev = find_device(-1, name, 0);
> +	if (!dev)
> +		return -EBADF;
> +
> +

> +	mutex_lock_interruptible(&dev->mutex);

The return value of mutex_lock_interruptible() must be checked.

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
