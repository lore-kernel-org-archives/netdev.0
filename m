From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in
	network devices
Date: Wed, 29 Jul 2009 06:47:26 -0400
Message-ID: <20090729104726.GA17410@hmsreliant.think-freely.org>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net> <4A6D52FF.2030008@inria.fr> <4A6D5E1E.3090907@gmail.com> <20090727105554.GB15823@hmsreliant.think-freely.org> <4A700667.5080108@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49072 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbZG2Krj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 06:47:39 -0400
Content-Disposition: inline
In-Reply-To: <4A700667.5080108@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 10:20:55AM +0200, Brice Goglin wrote:
> Neil Horman wrote:
> >>> Is there an easy way to get this NUMA node from the application socket
> >>> descriptor?
> >>>       
> >> Thats not easy, this information can change for every packet (think of
> >> bonding setups, whith aggregation of devices on different NUMA nodes)
> >>
> >> We could add a getsockopt() call to peek this information from the next
> >> data to be read from socket (returns node id where skb data is sitting,
> >> hoping that NIC driver hadnt copybreak it (ie : allocate a small skb and
> >> copy the device provided data on it before feeding packet to network stack))
> >>
> >>     
> > Would a proc or debugfs interface perhaps be helpful here?  Something that
> > perhaps showed a statistical distribution of how many packets were received by
> > each process on each irq (operating under the assumption that each rx queue has
> > its own msi irq, giving us an easy identifier).
> >   
> 
> It could be intereting. But unprivileged user processes cannot read
> /proc/irq/*/smp_affinity, so they would not be able to translate your
> procfs information into a binding hint.
> 
I don't think you'd need read access to the irq affinity files.  If the above
debugfs/proc information were exported to indicate which numa node or cpu the
allocated skb were local to, that could be used by the process to set its
scheduler affintiy via taskset.

Neil

> Brice
> 
> 
