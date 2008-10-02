From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Thu, 2 Oct 2008 09:14:03 -0400
Message-ID: <20081002131403.GA6261@hmsreliant.think-freely.org>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com> <20080930184249.GC6496@hmsreliant.think-freely.org> <20081002071631.GB20406@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60922 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbYJBNQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 09:16:15 -0400
Content-Disposition: inline
In-Reply-To: <20081002071631.GB20406@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 11:16:31AM +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Sep 30, 2008 at 02:42:49PM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> > I think what you're looking for here is a simple standard deviation, isn't it?
> > Compute the mean chain legnth, sum the squares of the deviations of each chain
> > and take the square root.  Any individual chain longer than the mean chain
> > length + 1 standard deviation can be considered an 'outlier' and therefore
> > trigger a rebuild of the table for that net namespace.
> > 
> > I full well realize that thats easier said than done, but does that seem about
> > right?  If so, I can start working on trying to build something to accomplish
> > that.
> 
> You are right, but in kernel it may not that simple to get a square
> root... We can probably play with logarithms though.
> 

I don't in truth, need a quare root operation (at least I don't think I do).
I'm abel to compute the variance rather easily, with a walk of the hash table,
then I approximate the square root by use of a for loop in which I square the
iterator and compare it to the variance.  The iterator when squared that is
closest to the variance is taken as my standard deviation.  As mentioned
previously 4*sd should cover almost all of my sample universe, identifying any
remaining outliers as the trigger for a rebuild.

Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
