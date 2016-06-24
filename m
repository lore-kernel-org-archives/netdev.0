From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Fri, 24 Jun 2016 13:47:53 +0200
Message-ID: <20160624114753.GB28345@orbyte.nwl.cc>
References: <1466703254-5174-1-git-send-email-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6D5F4E3E8D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51688 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbcFXLrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 07:47:08 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4E3E8D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 24, 2016 at 09:17:07AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 23 June 2016 18:34
> >
> > This is v3 of my C99-style initializer related patch series.
> ...
> 
> It would be interesting to know how this affect the kernel code size?
> 
> While gcc will generate a memset() call for 'struct foo = {0}' if you
> initialise some members it might generate explicit zeroing instructions
> for all the other words of the structure.
> 
> I've seen gcc use memset() to zero the end of a structure, it may use
> memset() for large gaps earlier in the structure.
> 
> But if you initialise a byte half way down you are very unlikely to
> get a single memset() and then a write to the single location.

I did a standard build ('make distclean; make') before and after this
commit in my tree. The 'ip' binary didn't change in size at all (quite
surprising), the 'tc' binary shrunk by 48 bytes.

Cheers, Phil
