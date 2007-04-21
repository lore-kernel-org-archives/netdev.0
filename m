From: David Miller <davem@davemloft.net>
Subject: Re: SIOCGIFCOUNT
Date: Sat, 21 Apr 2007 10:40:47 -0700 (PDT)
Message-ID: <20070421.104047.41636018.davem@davemloft.net>
References: <200704210004.51278.ak@suse.de>
	<20070420.154133.76947512.davem@davemloft.net>
	<200704211148.52705.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753952AbXDURkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 13:40:53 -0400
In-Reply-To: <200704211148.52705.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sat, 21 Apr 2007 11:48:52 +0200

> On Saturday 21 April 2007 00:41:33 David Miller wrote:
> > From: Andi Kleen <ak@suse.de>
> > Date: Sat, 21 Apr 2007 00:04:51 +0200
> > 
> > > 0x8938 is SIOCGIFCOUNT. As far as I can see it is only defined in
> > > sockios.h, but not implemented?
> > >
> > > Should it be removed from the include file or implemented?
> > 
> > Unless we can be %100 certain not one build will break by removing it,
> > we should keep it around.
> 
> Ok, but should it not be implemented for the non compat case too?
> I assume java has some reason to call it.

It probably just is one of those silly:

#ifdef SIOCGIFCOUNT
	ret = try_to_use_SIOCGIFCOUNT();
#endif

type code blocks that we find in just about every wonky
source tree out there.

There is no reason to add an implementation of it, and
the compat layer should just return the same error
code that the non-compat code will.
