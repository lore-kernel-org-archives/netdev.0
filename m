From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] RX/close vcc race with
 solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 17:04:07 +0100
Message-ID: <1275926647.17903.5077.camel@macbook.infradead.org>
References: <201006071510.o57FA6uP010212@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55652 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab0FGQEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 12:04:10 -0400
In-Reply-To: <201006071510.o57FA6uP010212@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 11:10 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1275920035.17903.4998.camel@macbook.infradead.org>,David Woodhouse 
> writes:
> >On Mon, 2010-06-07 at 09:44 -0400, Chas Williams (CONTRACTOR) wrote:
> >> vcc's are really sockets, so you could just increase the refcount --
> >> sock_hold().
> >
> >There are rules about where we're allowed to call sock_hold(), and I
> >don't think our find_vcc() functions can be made to meet them.
> 
> if you are using find_vcc() then you should already have a lock on the
> hash table for the vccs.  you can safely increment the ref count at
> this point.

You can still hit the oops that way -- br2684_push() is setting
vcc->user_back to NULL before the final sock_put() anyway, and that's
what was causing the oops.

> >In that case I think we might as well stick with the RCU-like solution I
> >already implemented in the vcc close function -- which is just to wait
> >for the tasklet to complete, thus ensuring that it's no longer using the
> >defunct vcc.
> 
> the driver shouldnt close the vcc while the tasklet is running and
> using the vcc in question.  i guess the safest thing is to simply
> do as you are doing and not close while running the tasklet.

OK. :)

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

