From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: We have FUSE, could we have NUSE ?
Date: Thu, 8 Mar 2007 12:53:20 +0200
Message-ID: <20070308105320.GB3883@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:56663 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXCHKxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 05:53:22 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540234AbXCHKxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 12:53:20 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(somebody should invent a "better" name for this)

We do have a support of file-system engine in userspace process.
Could we have a socket interfaced network protocol engine in userspace ?

I would like to place things like AX.25 service into userspace, but have
application codes to use kernel socket API (and even ABI) as if the service
is in the kernel.

Required bandwidth for many of these protocols is quite small, therefore
having those within the kernel is unnecessary.  (Not to mention that quite
many system integrators choose not to turn them on...)


The aim of "NUSE" from applications point of view would be to be
indistinguishable from kernel implemented services.

What would this require from the service hook side ?
  - Socket read and write can be trivialishly done
    like a pipe in between processes
  - Somehow pass ancilliary data for:
     - socket, socketpair
     - connect, bind
     - accept
     - listen
     - getpeername, getsockname
     - sendto, send
     - recvfrom, revc
     - setsockopt, getsockopt
  - poll / epoll ?

Death of the protocol engine process must also destroy all existing
sockets of the served protocol type, and refuse to generate any new
sockets of the type.


The first protocol that I have in mind to implement on top of this service
does not need very much of local sockets.
(It is called "STANAG-5066" - radio data communication on HF frequencies.
Specification is written by NATO, thus "STANAG", but my use plans for it
are more along the AX.25 ham-radio things.)


/Matti Aarnio
