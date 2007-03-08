From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: We have FUSE, could we have NUSE ?
Date: Thu, 8 Mar 2007 08:57:54 -0500
Message-ID: <20070308135754.GA5323@tuxdriver.com>
References: <20070308105320.GB3883@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4304 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbXCHOcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 09:32:10 -0500
Content-Disposition: inline
In-Reply-To: <20070308105320.GB3883@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 12:53:20PM +0200, Matti Aarnio wrote:

> The aim of "NUSE" from applications point of view would be to be
> indistinguishable from kernel implemented services.
> 
> What would this require from the service hook side ?
>   - Socket read and write can be trivialishly done
>     like a pipe in between processes
>   - Somehow pass ancilliary data for:
>      - socket, socketpair
>      - connect, bind
>      - accept
>      - listen
>      - getpeername, getsockname
>      - sendto, send
>      - recvfrom, revc
>      - setsockopt, getsockopt
>   - poll / epoll ?

It is certainly possible to do this by implementing your own socket
family.  I did such a thing as infrastructure for talking to network
processors in a former life.  In that case the socket code was talking
to other kernel code, but getting it to coordinate w/ userland is
largely a SMOP.  You might consider using (generic?) netlink for
your backend communications to the userland daemon.  In addition,
there might be other kernel extensions required (e.g. dynamic socket
family allocation?).

> Death of the protocol engine process must also destroy all existing
> sockets of the served protocol type, and refuse to generate any new
> sockets of the type.

That's up to you (or whomever implements the kernel code).

> The first protocol that I have in mind to implement on top of this service
> does not need very much of local sockets.
> (It is called "STANAG-5066" - radio data communication on HF frequencies.
> Specification is written by NATO, thus "STANAG", but my use plans for it
> are more along the AX.25 ham-radio things.)

Nifty. :-)

John
-- 
John W. Linville
linville@tuxdriver.com
