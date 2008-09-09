From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Internet-Draft on Port Randomisation
Date: Tue, 9 Sep 2008 22:11:33 +0200
Message-ID: <20080909201133.GG7714@one.firstfloor.org>
References: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com> <48C60284.2070402@vyatta.com> <878wu1tmup.fsf@basil.nowhere.org> <20080909.130424.170861701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, stephen.hemminger@vyatta.com,
	eugeneteo@kernel.sg, netdev@vger.kernel.org, eteo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47527 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbYIIUHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:07:51 -0400
Content-Disposition: inline
In-Reply-To: <20080909.130424.170861701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 01:04:24PM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 09 Sep 2008 16:28:30 +0200
> 
> > [haven't read the draft] But you don't necessarily need a full global
> > lock for such a scheme. What works too is to access global state only
> > ever N accesses and pre-allocate a small range per CPU. While there's
> > still some global overhead then, it happens significantly less. My old
> > alternative ipid setup algorithm worked this way.
> 
> Should work well on a 64K cpu system.

If you make N large enough it can work with pretty much any number of CPUs. 
The main drawback is that it's losing random bits the larger N is, but then 
64k is not really remotely secure anyways.

Due to the later reason I doubt such a change is very interesting.
Also there's the issue on fully preemptible kernels.

If you wanted a more secure port space what would like make more 
sense is to use IPv6 and use e.g. 32bit out of the local network
address space for port randomization too.

-Andi
-- 
ak@linux.intel.com
