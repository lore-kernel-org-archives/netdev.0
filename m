From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 05:22:17 -0400
Message-ID: <48AE8549.6090705@garzik.org>
References: <20080821185402.GD31526@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux-Driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59148 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbYHVJWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2008 05:22:21 -0400
In-Reply-To: <20080821185402.GD31526@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> Hi Jeff,
> 
> Please find our new 10Gb ethernet driver at the following site:
> 
> ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge
> 
> There are two files at this location:
> qlge-aug212008.patch - A full patch that is buildable on the latest netdev/upstream kernel.
> qlge-aug212008.tar.bz2 - A zip file of the source code at drivers/net/qlge/*
> 
> We are targeting this driver for 2.6.28 release.  We look forward to any and all comments.
> 
> Notes:
> 1) The file qlge_mpi.c (Management Port Interface) is mostly stubbed right now but will have functionality to handle setting up wake-on-lan and getting/setting link paramters.
> 2) Please ignore "#ifdef PALLADIUM".  It will be removed going forward as it's currently used for a test platform.

OK, just skimmed the whole thing (i.e. no in-depth analysis of locking, 
etc.)

Initial thoughts...

- its a nice clean driver
- I have not examined the interrupt and completion paths in depth, but 
they looked unusual enough to warrant additional analysis [on my part]. 
  - There are more spinlocks than usual, raising an eyebrow
- The kmap use is interesting
- I also wonder if heavy use of atomic_t might not be more expensive 
than spinlocking a section, then using normal variables.
- want more info on shadow (buffering?) scheme
- are hardware docs or more info available?
- most drivers do not need LICENSE files, is that really necessary?

