From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net v2] tg3: prevent ifup/ifdown during PCI error
 recovery
Date: Tue, 2 Sep 2014 10:32:56 -0700
Message-ID: <1409679176.16238.2.camel@prashant>
References: <1409574117-19435-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52087 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbaIBRlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 13:41:46 -0400
In-Reply-To: <1409574117-19435-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-01 at 14:21 +0200, Ivan Vecera wrote:
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

Acked-by: Prashant Sreedharan <prashant@broadcom.com>


--
