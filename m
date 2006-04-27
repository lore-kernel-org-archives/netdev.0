From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 23:27:24 -0700 (PDT)
Message-ID: <20060426.232724.07687472.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AEE0@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060426.230812.13989689.davem@davemloft.net>
	<200604270817.36041.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, jeff@garzik.org, kelly@au1.ibm.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35499
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964957AbWD0G1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 02:27:47 -0400
To: ak@suse.de
In-Reply-To: <200604270817.36041.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 27 Apr 2006 08:17:35 +0200

> On Thursday 27 April 2006 08:08, David S. Miller wrote:
> 
> > I'm currently assuming that the protocol processing is still done in
> > the kernel on behalf of the user context, so the issues you raise
> > really aren't relevant.
> > 
> > We really shouldn't be jumping the gun so far into the implementation
> > as others seem to be doing.  Let's do it simple first and see if
> > putting things all the way to userspace even is necessary.
> 
> I still have my doubts about doing that securely anyways.

The NIC has a descriptor of buffers, the NIC can thus DMA right
into this buffer which only contains packet data and nothing
else outside of those packets.

The software implementation, of course, will not be able to do
this and will need to copy.

> One thing I would like to see is some generic code for the channels.
> It might be interesting to try if that data structure could be used
> in other parts of the kernel that pass objects around (like VM or block
> layer) 

Seconded.  This should be easy once we have the basic global input
queue channel working.

I even put it in include/linux/netchannel.h in my vj-2.6 tree sort
of to hint at this. :)

