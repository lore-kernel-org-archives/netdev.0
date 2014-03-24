From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [net-next 15/16] igb: Fix Null-pointer dereference in
 igb_reset_q_vector
Date: Mon, 24 Mar 2014 21:57:16 +0100
Message-ID: <20140324205716.GA4330@cpaasch-mac>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <0082c389c1d6488cb5cf473ff1bc26e2@UCL-MBX03.OASIS.UCLOUVAIN.BE>
 <20140323143125.GC5028@cpaasch-mac>
 <6af5c43984d241daa37714ea8f98ab53@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50837 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbaCXU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 16:57:22 -0400
Content-Disposition: inline
In-Reply-To: <6af5c43984d241daa37714ea8f98ab53@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/14 - 20:49:30, Jeff Kirsher wrote:
> On Sun, 2014-03-23 at 15:31 +0100, Christoph Paasch wrote:
> > On 21/03/14 - 12:10:05, Jeff Kirsher wrote:
> > > From: Christoph Paasch <christoph.paasch@uclouvain.be>
> > > 
> > > When igb_set_interrupt_capability() calls
> > > igb_reset_interrupt_capability() (e.g., because CONFIG_PCI_MSI is
> > unset),
> > > num_q_vectors has been set but no vector has yet been allocated.
> > > 
> > > igb_reset_interrupt_capability() will then call igb_reset_q_vector,
> > > which assumes that the vector is allocated. As this is not the case,
> > we
> > > are accessing a NULL-pointer.
> > > 
> > > This patch fixes it by checking that q_vector is indeed different
> > from
> > > NULL.
> > > 
> > > Fixes: 02ef6e1d0b0023 (igb: Fix queue allocation method to
> > accommodate changing during runtime)
> > > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > > Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > Hello Jeff,
> > 
> > shouldn't this one rather be for 'net' instead of 'net-next'? Because
> > 02ef6e1d0b0023 is part of 3.14-rc1.
> 
> Yes, but being that it is late in the -rcX cycle and 3.14 is expected to
> be released anytime now, it was not prudent to try and push this in
> right before the window closes.  It is better to have -stable pick this
> up once Linus releases 3.14.  Same goes for your other patch.
> 
> So once Linus releases 3.14 and Linus merges in Dave's net-next tree for
> 3.15, I will notify the stable maintainers that your 2 patches need to
> be picked up for 3.14.x stable trees.

Ok, fair enough.


Cheers,
Christoph
