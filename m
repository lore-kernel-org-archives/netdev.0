From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] RX/close vcc race with solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 12:37:52 -0400
Message-ID: <201006071637.o57GbqWd002514@thirdoffive.cmf.nrl.navy.mil>
References: <1275926647.17903.5077.camel@macbook.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:42468 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab0FGQie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 12:38:34 -0400
In-reply-to: <1275926647.17903.5077.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1275926647.17903.5077.camel@macbook.infradead.org>,David Woodhouse 
writes:
>You can still hit the oops that way -- br2684_push() is setting
>vcc->user_back to NULL before the final sock_put() anyway, and that's
>what was causing the oops.

i dont understand.  if you do a sock_hold() in find_vcc(), and then call
vcc->push() you should be able to call vcc->push() and then sock_put().
the solos driver is broken since the result find_vcc() does not do
anything to keep the resulting vcc from evaporating.  find_vcc() should
be taking a reference on the vcc, or the lock needs to held around
any usage of the results from find_vcc().

