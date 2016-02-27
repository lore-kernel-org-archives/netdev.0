From: Adam Seering <adam@seering.org>
Subject: Re: [PATCH] appletalk: Pass IP-over-DDP packets through when
 'ipddp0' interface is not present
Date: Fri, 26 Feb 2016 23:49:35 -0500
Message-ID: <1456548575.4577.101.camel@seering.org>
References: <1456237153.4577.35.camel@seering.org>
	 <20160225.143353.284231681606348501.davem@davemloft.net>
	 <1456447597.4577.49.camel@seering.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comomta-po-02v.sys.comcast.net ([96.114.154.158]:38894 "EHLO
	comomta-po-02v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349AbcB0EuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 23:50:03 -0500
In-Reply-To: <1456447597.4577.49.camel@seering.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-25 at 19:46 -0500, Adam Seering wrote:
> On Thu, 2016-02-25 at 14:33 -0500, David Miller wrote:
> > From: Adam Seering <adam@seering.org>
> > Date: Tue, 23 Feb 2016 09:19:13 -0500
> > 
> > > Let userspace programs transmit and receive raw IP-over-DDP
> > > packets
> > > with a kernel where "ipddp" was compiled as a module but is not
> > loaded
> > > (so no "ipddp0" network interface is exposed).  This makes the
> > "module
> > > is not loaded" behavior match the "module was never compiled"
> > behavior.
> > > 
> > > Signed-off-by: Adam Seering <adam@seering.org>
> > 
> > I think a better approache is to somehow autoload the module.
> 
> Could you elaborate?  Specifically: the kernel currently suppresses
> packets on behalf of the module even after the module is unloaded. 
>  How
> would autoloading the module help with that?

Re-reading this thread -- perhaps I didn't explain the problem well. 
 Let me elaborate.  Apologies if this is obvious to folks here:

I want my userspace program to send and receive DDP packets that
encapsulate IP traffic.

Problem:  On some kernel builds, these DDP packets are never delivered
to the DDP socket opened by my program.

The "ipddp" module is supposed to prevent those packets from being
delivered to DDP sockets when it is loaded -- it handles them itself. 
 Ok, that's fine; I just want to unload that module, right?

Wrong!  Unloading the module is not sufficient.  I have to re-compile
the kernel with the module disabled completely.  (No other config
options; simply setting the module to not build does the trick.)
whose sole purpose is to handle it.  If not, unload it.  This patch
makes that happen.  Thoughts?

Thanks,
Adam
