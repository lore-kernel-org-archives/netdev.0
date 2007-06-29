From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: a maze of twisty stats, most different
Date: Fri, 29 Jun 2007 11:21:54 -0700
Message-ID: <OFAD87D0AB.C0688B5F-ON88257309.006374DE-88257309.0064D4D0@us.ibm.com>
References: <p73abui4qj4.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ak@suse.de, Chris Snook <csnook@redhat.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Rick Jones <rick.jones2@hp.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38727 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbXF2SWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 14:22:01 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5TIM1jH010798
	for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 14:22:01 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5TIM0JK217796
	for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 12:22:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5TIM0Ds027272
	for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 12:22:00 -0600
In-Reply-To: <p73abui4qj4.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ak@suse.de wrote on 06/29/2007 10:30:23 AM:

> David Stevens <dlstevens@us.ibm.com> writes:
> 
> > I think there's a more general problem that's a huge hassle. There are 

> > lots of
> > new SNMP MIB's, but no conventions (that I'm aware of, at least) to 
allow 
> > for
> > changes to the /proc entries that get them to applications. 
> 
> Actually /proc/net/snmp and netstat -s are extensible. If you add a new
> MIB or field there it should just show up in netstat -s. It won't know 
about
> the text decoding that is done for the early traditional MIBs, but that
> is already not there for most of the newer fields.

That works ok for some things, like new global counters, but some
items really fit best in existing files and the concern there is about
other uses of them beyond the standard tools.
        Examples:
-addition of route age in /proc/net/route and /proc/net/ipv6_route
-per-group data in /proc/net/igmp & igmp6
-per-interface MLD MIB info, which ought to go with other per-interface 
data

        I think everything that uses this kind of interface ought to do
label matching, so additional columns in a row (anywhere in the row)
would just be skipped/ignored by things that don't understand them,
and similarlarly for single-row tagged items. You can do that in scripts
with awk, but if existing items don't, they'll break.
        On the other hand, we don't want to create a new instance for
every addition or modification, so it seems the middle ground is to
go with new entries now and state that scripts and code that don't
match tags and handle changes in the format in the future are broken.
        We could dump everything in /proc/net/snmp{,6}, of course,
but I'm not sure it's a good idea to replicate all the routing and 
interface
data that is not there now just to get a few additional fields for those
items.

                                                +-DLS


