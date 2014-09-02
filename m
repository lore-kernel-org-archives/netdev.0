From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tg3: prevent ifup/ifdown during PCI error
 recovery
Date: Tue, 02 Sep 2014 13:02:34 -0700 (PDT)
Message-ID: <20140902.130234.1386697848957363743.davem@davemloft.net>
References: <1409574117-19435-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaIBUCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:02:35 -0400
In-Reply-To: <1409574117-19435-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon,  1 Sep 2014 14:21:57 +0200

> The patch fixes race conditions between PCI error recovery callbacks and
> potential ifup/ifdown.
> 
> First, if ifup (tg3_open) is called between tg3_io_error_detected() and
> tg3_io_resume() then tp->timer is armed twice before expiry. Once during
> tg3_open() and again during tg3_io_resume(). This results in BUG
> at kernel/time/timer.c:945.
> 
> Second, if ifdown (tg3_close) is called between tg3_io_error_detected()
> and tg3_io_resume() then tg3_napi_disable() is called twice without
> a tg3_napi_enable between. Once during tg3_io_error_detected() and again
> during tg3_close(). The tg3_io_resume() then hangs on rtnl_lock().
> 
> v2: Added logging messages per Prashant's request
> 
> Cc: Prashant Sreedharan <prashant@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
