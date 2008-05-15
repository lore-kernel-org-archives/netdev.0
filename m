From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 18:34:43 -0400
Message-ID: <20080515223443.GR18825@mit.edu>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515215517.GI1936@cs181133002.pp.htv.fi> <9a8748490805151513j74f9b99dla900ebc636941636@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mpm@selenic.com
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.church-of-our-saviour.org ([69.25.196.31]:36501 "EHLO
	thunker.thunk.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754558AbYEOWfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:35:08 -0400
Content-Disposition: inline
In-Reply-To: <9a8748490805151513j74f9b99dla900ebc636941636@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 12:13:39AM +0200, Jesper Juhl wrote:
> My point is that the rate (and timing between) syscalls is depending
> on very many factors; the kernel version (and configuration), the
> software installed, the software currently executing, the state of the
> software currently executing, the number of apps executing, the amount
> of network traffic, the accuracy of the hardware clock, the speed of
> (various) IO sources (network, disk, USB, etc), the speed (and type)
> of the CPU, the speed of memory. And various other things.

It Depends.

For certain workloads, a lot of these issues might just boil out, or
not result in as much entropy as you think.  Think about a certificate
server which doesn't get much traffic, but when it is contacted, it is
expected to create new high security RSA keys and the public key
certificates to go with it.  If the attacker knows the machine type,
distribution OS loaded, etc., it might not be that hard to brute force
guess many of the factors you have listed above.

Basically the question has always been one of the overhead to collect
and boil down any input data (which after all, any user space process
can send arbitrary data into the entropy pool via "cat my_secret_data
> /dev/random") which will never hurt and might help.  The tricky bit
is estimating how much "entropy" should be ascribed to data which is
sent into the entropy pool, and this is where you have to be very
careful.

If you screw the entropy credit information then security of
/dev/random will be impacted.  /dev/urandom won't be impacted since it
doesn't care about the entropy estimation.  That's why only root is
allowed to use the ioctl which atomically sends in some "known to be
random" data and the entropy credit ascribed to that data.

	     	     	     	    	     	- Ted
