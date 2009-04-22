From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:46:18 -0700 (PDT)
Message-ID: <20090421.234618.181879214.davem@davemloft.net>
References: <20090422061006.GB27688@bx9.net>
	<20090421.233403.83067664.davem@davemloft.net>
	<20090422064159.GA4221@bx9.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: greg@blekko.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbZDVGqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 02:46:25 -0400
In-Reply-To: <20090422064159.GA4221@bx9.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Lindahl <greg@blekko.com>
Date: Tue, 21 Apr 2009 23:41:59 -0700

> On Tue, Apr 21, 2009 at 11:34:03PM -0700, David Miller wrote:
> 
>> People use poll() to avoid -EAGAIN and blocking, they expect the bits
>> to tell them what fd's they can work on to do real work.
> 
> My point is that EAGAIN happens already. So you can't claim that
> returning it in accept() breaks the interface, when it's common enough
> that today's user-level network code already handles it.

EAGAIN does not happen if the application calls poll(), gets
an indication that connections are available, and then
immediately calls accept() on the indicated FD.

It can only happen if it calls accept() multiple times after such a
poll() call _OR_ it does not control multi-threaded access to the
listen file descriptor.

This new behavior from TOMOYO would make accept() return -EAGAIN in
cases which are of no fault of the application.  It is definitely
unexpected behavior.

If overly anal apps "code for it" that is entirely besides the point.
What we have to be concerned for, from a kernel behavioral standpoint,
is that some apps "might not code for it".  This is why we don't
change behavior.
