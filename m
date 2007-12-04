From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 13:01:09 -0700
Message-ID: <m1k5nuw7p6.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>
	<20071201202354.672aed18@freepuppy.rosehill>
	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>
	<m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
	<47544896.7070101@candelatech.com>
	<m18x4axrx2.fsf@ebiederm.dsl.xmission.com>
	<4755A2FD.9020608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58711 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbXLDUDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 15:03:00 -0500
In-Reply-To: <4755A2FD.9020608@candelatech.com> (Ben Greear's message of "Tue,
	04 Dec 2007 10:57:01 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> I have a module that has a collection of 2-port bridges.  These bridges are used
> for emulation
> purposes (somewhat similar to netem's feature set).  Each bridge is logically
> independent
> of the others.   To set up a bridge, I do something like:
>
> echo add_my_bridge my_br1 eth0 eth1 > /proc/net/foo/config

Interesting.  Currently /proc/net is also per network namespace.
So normally I would say just call get_proc_net from inside your
proc handler and all would be well.

At another location in /proc (not under /proc/net) I would just do:
dev_get_by_name(current->nsproxy->net_ns, "ethX");

I would probably be paranoid and grab current->nsproxy->net_ns
when the file was opened and put it when the file was closed
just to ensure that if someone opened it and then passed
the file descriptor to someone else there were not any
weird little races.  But I don't expect that is a problem
in your case.

> Personally, it seems useful for my module to be able to have eth0 in one
> namespace
> and eth1 in another, but I won't complain if they both have to be in the same
> namespace
> or even just in the default namespace due to GPL symbol issues.

It probably is easiest to move the devices after your module has
bridged them.

Eric
