From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] RX/close vcc race with
 solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 15:13:55 +0100
Message-ID: <1275920035.17903.4998.camel@macbook.infradead.org>
References: <201006071344.o57DiiCx018593@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57578 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab0FGON6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 10:13:58 -0400
In-Reply-To: <201006071344.o57DiiCx018593@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 09:44 -0400, Chas Williams (CONTRACTOR) wrote:
> vcc's are really sockets, so you could just increase the refcount --
> sock_hold().

There are rules about where we're allowed to call sock_hold(), and I
don't think our find_vcc() functions can be made to meet them.

> however, i think the close routines dont really expect this behavior
> so the card driver's vcc close might need to be changed to wait around
> if the refcount on the vcc is > 1.

In that case I think we might as well stick with the RCU-like solution I
already implemented in the vcc close function -- which is just to wait
for the tasklet to complete, thus ensuring that it's no longer using the
defunct vcc.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

