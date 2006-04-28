From: Rusty Russell <rusty@rustcorp.com.au>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Sat, 29 Apr 2006 08:17:01 +1000
Message-ID: <1146262622.8029.63.camel@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F143B10A@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53147 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751728AbWD1WRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 18:17:30 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143B10A@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-28 at 10:55 -0700, Caitlin Bestler wrote:
> vj_netchannels represent a strategy of minimizing
> registration/pinning costs even if it means paying for an extra copy.
> Because the extra copy is closely tied to the activation of the data
> sink consumer the cost of that extra copy is greatly reduced because
> it places the data in the cache immediately before the application
> will in fact use the received data.

Just to be clear here: I agree with Dave that without classifying
hardware, there's no point (and much pain) in going all the way to
userspace with the channel (ie. mmap).  If you're going to copy anyway,
might as well do it in the socket's read() call: then the user can then
aim the copy exactly where they want, too.  We'll need that TCP code in
the kernel for the foreseeable future anyway 8)

However, in future, if intelligent cards exist, having an API which lets
them do zero-copy and not overly penalize less intelligent cards makes
sense.

Side note: my Xen I/O patches allow the implementation of exactly this
kind of virtual hardware (no coincidence 8), so intelligent cards might
not be as far away as you think...

> Also keep in mind that once the issues are resolved to allow the
> netchannel rings to be directly visible to a user-mode client that
> enhanced/specialized interfaces can easily be added in user-mode
> libraries. So focusing on supporting existing conventional interfaces
> is probably the best approach for the initial efforts.

Absolutely.

Cheers!
Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

