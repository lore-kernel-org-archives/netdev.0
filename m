From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] RX/close vcc race with solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 11:10:06 -0400
Message-ID: <201006071510.o57FA6uP010212@thirdoffive.cmf.nrl.navy.mil>
References: <1275920035.17903.4998.camel@macbook.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:42775 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab0FGPKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 11:10:41 -0400
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1275920035.17903.4998.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1275920035.17903.4998.camel@macbook.infradead.org>,David Woodhouse 
writes:
>On Mon, 2010-06-07 at 09:44 -0400, Chas Williams (CONTRACTOR) wrote:
>> vcc's are really sockets, so you could just increase the refcount --
>> sock_hold().
>
>There are rules about where we're allowed to call sock_hold(), and I
>don't think our find_vcc() functions can be made to meet them.

if you are using find_vcc() then you should already have a lock on the
hash table for the vccs.  you can safely increment the ref count at
this point.

>In that case I think we might as well stick with the RCU-like solution I
>already implemented in the vcc close function -- which is just to wait
>for the tasklet to complete, thus ensuring that it's no longer using the
>defunct vcc.

the driver shouldnt close the vcc while the tasklet is running and
using the vcc in question.  i guess the safest thing is to simply
do as you are doing and not close while running the tasklet.
