From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ss -p is much too slow
Date: Sat, 31 Jul 2010 19:33:51 -0700
Message-ID: <20100731193351.2b703437@nehalam>
References: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
	<20100628.162139.59679342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sphink@gmail.com, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33579 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419Ab0HACdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 22:33:53 -0400
In-Reply-To: <20100628.162139.59679342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jun 2010 16:21:39 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Steve Fink <sphink@gmail.com>
> Date: Wed, 9 Jun 2010 11:42:38 -0700
> 
> > On closer inspection, it appears that ss -p does a quadratic scan. It
> > rescans every entry in /proc/*/fd/* repeatedly (once per listening
> > port? per process? I don't remember what I figured out.)
> > 
> > I humbly suggest that this is not a good idea.
> 
> Yep, this is junk.  Please give this patch a try:
> 
> ss: Avoid quadradic complexity with '-p'
> 
> Scan the process list of open sockets once, and store in a hash
> table to be used by subsequent find_user() calls.
> 
> Reported-by: Steve Fink <sphink@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Applied


-- 
