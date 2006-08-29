From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 20:10:21 +0200
Message-ID: <20060829181021.GA3470@postel.suug.ch>
References: <20060829082435.GA2676@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jan Beulich <jbeulich@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49360 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965228AbWH2SKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 14:10:00 -0400
To: Olaf Kirch <okir@suse.de>
Content-Disposition: inline
In-Reply-To: <20060829082435.GA2676@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Olaf Kirch <okir@suse.de> 2006-08-29 10:24
> we had bug reports from people seeing lots of spurious messages
> like the following:
> 
> kernel: peth0: received packet with own address as source address.
> 
> and
> 
> xenbr0: duplicate address detected!
> 
> This is on a Xen enabled machine, with lots of Xen machines on the
> same network.
> 
> When the Xen code configures the bridge device, this will do IPv6
> autoconfiguration for the interface, and since they use synthetic MAC
> addresses, there will be DAD collisions.
> 
> When the Xen people looked for a way to disable IPv6 autoconf of the
> bridge, they didn't find any way to do it without bringing up the
> device first (and thereby triggering DAD).

They didn't find any because there is no need to disable it. I
hardly think that the network stack should fix things that Xen
got wrong. Setting dev_addr to -1 is just plain wrong, other
virtual ethernet devices call random_ether_addr(), it's not a
new problem at all.
