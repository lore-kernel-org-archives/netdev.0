From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC] net/bridge: port based vlan filtering for bridges
Date: Wed, 11 Apr 2012 11:36:29 -0400
Message-ID: <20120411153629.GC17739@kvack.org>
References: <20120411151002.GA17739@kvack.org> <20120411083052.1ca6a6ef@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49170 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757252Ab2DKPga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 11:36:30 -0400
Content-Disposition: inline
In-Reply-To: <20120411083052.1ca6a6ef@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 11, 2012 at 08:30:52AM -0700, Stephen Hemminger wrote:
> On Wed, 11 Apr 2012 11:10:02 -0400
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> 
> > Hello folks,
> > 
> > Attached is the first stab at a patch to make it possible to filter packets 
> > received from other bridge ports based on the port number.  This can be used 
> > to emulate port based VLANs that some switches support.
> > 
> > The justification for this is a bit interesting.  Initially, I had been 
> > filtering packets using firewall rules.  Unfortunately, the number of 
> > filter rules becomes impossible to manage when trying to filter traffic 
> > between 100 different ports.  CPU overhead of the filters is also a major 
> > problem.
> > 
> > The particular use-case I'm dealing with is simulating wireless networks 
> > on a system using LXC containers.  Each guest has a veth device that is a 
> > member of the bridge, but the topology of which nodes can "hear" each other 
> > changes at runtime.
> > 
> > Comments/thoughts?
> > 
> 
> Nak. If firewall doesn't work then implement a better netfilter
> module.

That still results in the CPU overhead of packet duplication for each and 
every bridge port regardless of the port receiving the packet or not.  
Hmmmm, would a NF_HOOK in should_deliver be okay?

		-ben
-- 
"Thought is the essence of where you are now."
