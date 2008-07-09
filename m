From: Bill Fink <billfink@mindspring.com>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 01:47:58 -0400
Message-ID: <20080709014758.d59be0d8.billfink@mindspring.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com>
	<20080708134845.2372a483@speedy>
	<20080708180500.e8a61231.billfink@mindspring.com>
	<20080709052534.GA8157@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:46027 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYGIFsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 01:48:07 -0400
In-Reply-To: <20080709052534.GA8157@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jul 2008, Evgeniy Polyakov wrote:

> On Tue, Jul 08, 2008 at 06:05:00PM -0400, Bill Fink (billfink@mindspring.com) wrote:
> > BTW I believe there is one other important difference between the way
> > the tcp_rmem/tcp_wmem autotuning parameters are handled versus the way
> > the rmem_max/wmem_max parameters are used when explicitly setting the
> > socket buffer sizes.  I believe the tcp_rmem/tcp_wmem autotuning maximum
> > parameters are hard limits, with the default maximum tcp_rmem setting
> > being ~170 KB and the default maximum tcp_wmem setting being 128 KB.
> 
> Maximum tcp_wmem depends on amount of available RAM, but at least 64k.
> Maybe Reoland's distro set hard limit just to 128k...

Are you sure you're not thinking about tcp_mem, which is a function
of available memory, or has this been changed in more recent kernels?
The 2.6.22.9 Documentation/networking/ip-sysctl.txt indicates:

tcp_wmem - vector of 3 INTEGERs: min, default, max
	...
	max: Maximal amount of memory allowed for automatically selected
	send buffers for TCP socket. This value does not override
	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
	Default: 128K

I also ran a purely local 10-GigE nuttcp TCP test, with and without
autotuning (0.13 ms RTT).

Autotuning (standard 10-second TCP test):

# nuttcp 192.168.88.13
...
11818.0625 MB /  10.01 sec = 9906.0223 Mbps 100 %TX 72 %RX 0 retrans

Same test but with explicitly specified 1 MB socket buffer:

# nuttcp -w1m 192.168.88.13
...
11818.0000 MB /  10.01 sec = 9902.0102 Mbps 99 %TX 71 %RX 0 retrans

The TCP autotuning worked great, with both tests basically achieving
full 10-GigE line rate.  The test with the TCP autotuning actually
did slightly better than the test where an explicitly specified 1 MB
socket buffer was used, although this could just be within the margin
of error of the testing.

						-Bill
