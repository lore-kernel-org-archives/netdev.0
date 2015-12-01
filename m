From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 16:06:08 -0500
Message-ID: <20151201210608.GB23178@oracle.com>
References: <20151201080652.5cba6f8b@xeon-e3>
 <20151201.142847.1980856920707150414.davem@davemloft.net>
 <20151201122038.795305df@xeon-e3>
 <20151201.155725.733555238839381632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, hannes@stressinduktion.org,
	max@rfc2324.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18492 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbLAVGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:06:20 -0500
Content-Disposition: inline
In-Reply-To: <20151201.155725.733555238839381632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/01/15 15:57), David Miller wrote:

> >> > Also current versions of SNMP provide more useful information about
> >> > network interface slot information in ifDescription
> >> 
> >> Well if they do provide strings, then that is probably a better way
> >> forward than messing with the kernel.
> > 
> > It gives strings based on PCI information but nothing useful
> > on tunnels.
> 
> But at least in theory, that could be extended to do so right?

iirc even for the cisco NOS-es, the snmp ifindex for virtual interfaces
(tunnels, vpc, loopback) etc would not have any slot etc info, but
would have other things (specific to the virtual interface type, e.g.,
FEX interface index had something that was pertinent to fex)

But the bigger reason they had a immutable snmp-ifindex was that
the uspace networking applications could build state based on that
immutable index and hang on to that number, regardless of any renumbering
that happened due to HA/failover.

And, since they did not (in general) have to deal with random third
party apps, they did not have to deal with questions like "what should
POSIX/glibc APIs send - the immutable or the mutable index?" so it
was ok for them to have the complexity of two interface indices.

--Sowmini
