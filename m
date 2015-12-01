From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 01 Dec 2015 21:26:19 +0100
Message-ID: <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
References: <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
 <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
 <20151201.142749.1921315575696738796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: max@rfc2324.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48377 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752242AbbLAU0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:26:20 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 715E2207C2
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 15:26:19 -0500 (EST)
In-Reply-To: <20151201.142749.1921315575696738796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015, at 20:27, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 01 Dec 2015 17:02:23 +0100
> 
> > On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> >> > I'm not sure I understand how this would work- are we going to 
> >> > pin down the ifindex for some subset of interfaces?
> >> 
> >> I'm not sure what your idea is, but I guess we might mean the same
> >> thing:
> >> 
> >> What I have in mind is that the user can supply a list of (ifname ->
> >> ifindex) entries via a sysfs/procfs interface and if such a list is
> >> present, the kernel will search the list for every ifname which is
> >> registered and check if there is an entry. If there is, the ifindex
> >> for this entry is used. If there is no entry found for the given
> >> ifname, the usual algorithm is used (therefore inherently providing
> >> backward compatibility).
> > 
> > Sorry to ask because I don't like this feature at all. There was a lot
> > of work on stable interface names. Why do you need stable ifindexes,
> > which were never meant to be stable for a longer amount of time?
> 
> Because all the remote SNMP tools work with interface indexes, not names.

I know, but it should be terribly simply to patch SNMP tools to even
store the table of ifindex <-> name mappings persistently on the disk
and thus completely avoid this issue. Even though they can check on
interfaces if they have the same characteristics, e.g. tunnel to the
same destinations etc. Those are all policies which user space should
handle.

I agree it would make life much easier for user space if the kernel
would keep the ifindex stable over reboots etc. but for a much higher
costs at kernel maintenance.

Bye,
Hannes
