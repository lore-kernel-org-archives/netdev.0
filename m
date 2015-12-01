From: Maximilian Wilhelm <max@rfc2324.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 23:43:25 +0100
Message-ID: <20151201224325.GD14984@principal.rfc2324.org>
References: <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
 <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
 <20151201.142749.1921315575696738796.davem@davemloft.net>
 <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rfc2324.org ([31.172.8.67]:40645 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405AbbLAWn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 17:43:28 -0500
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1a3tdt-0005N9-82
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 23:43:26 +0100
Content-Disposition: inline
In-Reply-To: <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anno domini 2015 Hannes Frederic Sowa scripsit:

> On Tue, Dec 1, 2015, at 20:27, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Tue, 01 Dec 2015 17:02:23 +0100
> > 
> > > On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> > >> > I'm not sure I understand how this would work- are we going to 
> > >> > pin down the ifindex for some subset of interfaces?
> > >> 
> > >> I'm not sure what your idea is, but I guess we might mean the same
> > >> thing:
> > >> 
> > >> What I have in mind is that the user can supply a list of (ifname ->
> > >> ifindex) entries via a sysfs/procfs interface and if such a list is
> > >> present, the kernel will search the list for every ifname which is
> > >> registered and check if there is an entry. If there is, the ifindex
> > >> for this entry is used. If there is no entry found for the given
> > >> ifname, the usual algorithm is used (therefore inherently providing
> > >> backward compatibility).
> > > 
> > > Sorry to ask because I don't like this feature at all. There was a lot
> > > of work on stable interface names. Why do you need stable ifindexes,
> > > which were never meant to be stable for a longer amount of time?
> > 
> > Because all the remote SNMP tools work with interface indexes, not names.

That's indeed true and the underlying problem which brought us to this
idea.

> I know, but it should be terribly simply to patch SNMP tools to even
> store the table of ifindex <-> name mappings persistently on the disk
> and thus completely avoid this issue. Even though they can check on
> interfaces if they have the same characteristics, e.g. tunnel to the
> same destinations etc. Those are all policies which user space should
> handle.

How should net-snmp handle cases where new interfaces come up on old
and now unused numbers? What should it report? That would escalate the
problem a lot IMHO.

> I agree it would make life much easier for user space if the kernel
> would keep the ifindex stable over reboots etc. but for a much higher
> costs at kernel maintenance.

What would that cost be in the implementation I sketched before?

I don't quite see what the higher cost would be. I currently can
manually set an ifindex of my choosing for newly created GRE tunnels,
vlan interfaces and the like. So what would be the difference of
having the optional ability to push some of these predefined ifindexes
into the kernel and don't bother while creating the interface and
having the same outcome? Same effect but easier to use once set up.

Regarding the performance issues raised before the same question
applies: What's the difference if I create some / a lot of interfaces
with sparse ifindexes by using "ip link add foo index 1234" or by
having a list within the kernel.

I still consider this a feature worth and simple enough to implement
which would serve as a great option for people with such usage
scenarios.

Best
Max
-- 
"Does is bother me, that people hurt others, because they are to weak to face the truth? Yeah. Sorry 'bout that."
 -- Thirteen, House M.D.
