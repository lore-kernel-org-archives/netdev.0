From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI Express adapters...
Date: Tue, 3 Jul 2007 11:24:23 -0700
Message-ID: <200707031124.24529.inaky@linux.intel.com>
References: <4688F512.3030801@garzik.org> <200707021716.49637.inaky@linux.intel.com> <468A4CDE.5010808@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34899 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbXGCSY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 14:24:26 -0400
In-Reply-To: <468A4CDE.5010808@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 July 2007, Jeff Garzik wrote:
> Inaky Perez-Gonzalez wrote:
> > I don't think bitfields are broken. Maybe it's the compiler what should be fixed (*)
> 
> Then you do not understand bitfields.  It is -axiomatic- that bitfields 
> are more difficult for compilers to implement.
> 
> Access to bitfields are not atomic within the machine int in which they 
> are stored... you need to "unpack" the values stored in bitfields, even 
> if they are single-bit bitfields.

Which we do manually when we don't use bitfields. Again, conceptually,
there is no difference.

> You cannot set multiple bitfields at one time, without even more complex 
> data structures.  You cannot compare and test multiple bitfields at one 
>   time.

But I am not saying that you only use bitfields. There are cases where
they make the code much more readable (for me, at least), and cases
(like the one you mention) where they not [this is why I use unions,
btw]..

> ...
>  
> Finally, this is -nothing new-.  I've been telling other driver writers 
> not to use bitfields in their drivers.  Google for 'garzik' and 'bitfield'.

I know, I am just disagreeing. This is one of those things each person is
entrenched on and is impossible to change (like emacs vs vi).
