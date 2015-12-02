From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC] Stable interface index option
Date: Wed, 2 Dec 2015 09:03:35 -0200
Message-ID: <20151202110335.GA3597@mrl.redhat.com>
References: <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
 <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
 <20151201.142749.1921315575696738796.davem@davemloft.net>
 <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
 <20151201224325.GD14984@principal.rfc2324.org>
 <1449014338.3866712.455236865.50F81F7F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maximilian Wilhelm <max@rfc2324.org>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbbLBLDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 06:03:38 -0500
Content-Disposition: inline
In-Reply-To: <1449014338.3866712.455236865.50F81F7F@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Dec 02, 2015 at 12:58:58AM +0100, Hannes Frederic Sowa wrote:
> Hello,
> 
> On Tue, Dec 1, 2015, at 23:43, Maximilian Wilhelm wrote:
> > How should net-snmp handle cases where new interfaces come up on old
> > and now unused numbers? What should it report? That would escalate the
> > problem a lot IMHO.
> 
> ifindexes are only reused when the ifindex allocator wraps around which
> should hopefully take a while and that is exactly my point.
> 
> In general the ifindexes are designed to not be reused very fast. Most
> ifindex usage is in socket layer where one specifies which way a packet
> should go in sendto/msg calls to override routing lookups or use link
> local addresses. Imagine an application looks up an interface and
> determines the ifindex to send out data to an ipv6 link local address
> (which needs the ifindex obviously). If we don't bias the ifindex
> selection during device creation time the app will get an error and
> won't race with other tunnels being setup and can handle that
> accordingly because new tunnels simply have new ifindexes until the
> per-namespace counter wraps around. If we have name based policies we
> have to audit user space applications how they do interface name
> selection to protect them against reusing interface names. Based on your
> mail you simply already do ensure that interface names are unique, so
> your monitoring software should use just them.
> 
> I simply see this feature being misused way too easily.

This is very similar to processes and their pids. On (small) embedded
systems it's common that a given process will always have the same pid
after boot. Then for some reason a process is restarted and you want it
to have that same pid, which is not good.

Same semantics would apply, I think. Monitoring software has to know how
to handle with that change and cope with it.

I don't know the details but I know that it's also possible to monitor
processes via SNMP, meaning that monitoring apps must already do that
for processes, then why not for interfaces?

  Marcelo
