From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 0/9] VM deadlock avoidance -v10
Date: Wed, 17 Jan 2007 10:20:38 +0100
Message-ID: <1169025638.22935.114.camel@twins>
References: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
	 <20070117091206.GA9845@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.46.243.15] ([213.46.243.15]:41029 "EHLO
	amsfep12-int.chello.nl" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932158AbXAQJXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 04:23:25 -0500
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20070117091206.GA9845@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 10:12 +0100, Pavel Machek wrote:
> Hi!
> 
> > These patches implement the basic infrastructure to allow swap over networked
> > storage.
> > 
> > The basic idea is to reserve some memory up front to use when regular memory
> > runs out.
> > 
> > To bound network behaviour we accept only a limited number of concurrent 
> > packets and drop those packets that are not aimed at the connection(s) servicing
> > the VM. Also all network paths that interact with userspace are to be avoided - 
> > e.g. taps and NF_QUEUE.
> > 
> > PF_MEMALLOC is set when processing emergency skbs. This makes sense in that we
> > are indeed working on behalf of the swapper/VM. This allows us to use the 
> > regular memory allocators for processing but requires that said processing have
> > bounded memory usage and has that accounted in the reserve.
> 
> How does it work with ARP, for example? You still need to reply to ARP
> if you want to keep your ethernet connections.

ETH_P_ARP is fully processed (under PF_MEMALLOC).

ETH_P_IP{,V6} starts to drop packets not for selected sockets
(SOCK_VMIO) and processes the rest (under PF_MEMALLOC) with limitations;
the packet may never depend on user-space to complete processing.

