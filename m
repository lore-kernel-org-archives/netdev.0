From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 5/7] drivers/atm/eni.c: ensure arguments to request_irq and free_irq are compatible
Date: Sun, 11 Mar 2012 16:58:11 -0400
Message-ID: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
References: <1331494587-12196-6-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:54134 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2CKU75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 16:59:57 -0400
In-reply-to: <1331494587-12196-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i am pretty sure that request_irq() shouldnt be changed but rather
free_irq() changed.  the last argument of request_irq() is passed to the
interrupt routine (ent_int in this case).  if you change that you need
to update the interrupt routine.  fixing free_irq would be easier.

In message <1331494587-12196-6-git-send-email-Julia.Lawall@lip6.fr>,Julia Lawall writes:
>Convert call to request_irq so that the last argument is the same as the
>second argument of the subsequent call to free_irq.  Without this
>property, free_irq does nothing.
>
>I have chosen to keep the call to free_irq as is, because its second
>argument is more like its first argument.
