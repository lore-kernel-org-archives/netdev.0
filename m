From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Fun with if_bridge.h and br_private.h
Date: Mon, 3 May 2010 16:34:48 -0700
Message-ID: <20100503233448.GQ2597@linux.vnet.ibm.com>
References: <20100503191256.GA18110@linux.vnet.ibm.com>
 <20100503133613.0f2a61f7@nehalam>
 <201005032302.21860.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43627 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979Ab0ECXeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 19:34:50 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43NTYKZ010406
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 19:29:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o43NYnV91458322
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 19:34:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43NYmLD021650
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 19:34:49 -0400
Content-Disposition: inline
In-Reply-To: <201005032302.21860.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 03, 2010 at 11:02:21PM +0200, Arnd Bergmann wrote:
> On Monday 03 May 2010 22:36:13 Stephen Hemminger wrote:
> > > In file included from net/core/dev.c:104:
> > > include/linux/if_bridge.h:106: warning: "struct net_bridge_port" declared inside parameter list
> > > include/linux/if_bridge.h:106: warning: its scope is only this definition or declaration, which is probably not what you want
> > > net/core/dev.c:2331: error: conflicting types for "br_handle_frame_hook"
> > > include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> > > net/core/dev.c:2333: error: conflicting types for "br_handle_frame_hook"
> > > include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> > > 
> > > This happens because net/bridge/br_private.h includes if_bridge.h before
> > > it defines net_bridge_port.
> > > 
> > > Any thoughts on how best to allow handle_bridge() see the definition
> > > of struct net_bridge_port?
> > > 
> > 
> > Why not make it a void *, there is no reason to make core code depend
> > on br_private.h.
> 
> Ah, right. That's actually how I changed the definition of br_port to
> start with. Sorry Paul, I had totally forgotten about this.
> Not sure if we also need to change the br_handle_frame_hook prototype,
> I think the forward declaration for struct net_bridge_port that I had
> in my long patch was actually sufficient.

Well, that explains why I couldn't find the #include in your patch set.  ;-)

I am applying the void* change and the br_port() wrapper function, will
see how it goes!

							Thanx, Paul
