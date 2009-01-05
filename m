From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Mon, 5 Jan 2009 08:22:52 +0000
Message-ID: <20090105082252.GB4460@ff.dom.local>
References: <20090105064728.GE16185@xi.wantstofly.org> <20090104.235946.90553420.davem@davemloft.net> <20090105081136.GA4460@ff.dom.local> <20090105.001401.63730458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, jens.axboe@oracle.com, ben@zeus.com,
	opurdila@ixiacom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:11841 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbZAEIXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 03:23:00 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1443995ugf.37
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2009 00:22:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090105.001401.63730458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 12:14:01AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 5 Jan 2009 08:11:37 +0000
> 
> > On Sun, Jan 04, 2009 at 11:59:46PM -0800, David Miller wrote:
> > > From: Lennert Buytenhek <buytenh@wantstofly.org>
> > > Date: Mon, 5 Jan 2009 07:47:29 +0100
> > > 
> > > > tcp: don't mask EOF and socket errors on nonblocking splice receive
> > > > 
> > > > Currently, setting SPLICE_F_NONBLOCK on splice from a TCP socket
> > > > results in masking of EOF (RDHUP) and error conditions on the socket
> > > > by an -EAGAIN return.  Move the NONBLOCK check in tcp_splice_read()
> > > > to be after the EOF and error checks to fix this.
> > > > 
> > > > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > > 
> > > This change looks like the perfect fix for this problem.
> > > 
> > 
> > Actually, I wonder why this "if (flags & SPLICE_F_NONBLOCK)" can't
> > be skipped at all. Isn't "if (!timeo)" enough now?
> 
> Is it really the same condition in the end?

Yes!?

Jarek P.
