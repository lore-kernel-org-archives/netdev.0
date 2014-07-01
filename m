From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Tue, 01 Jul 2014 14:22:04 -0700
Message-ID: <87d2do93lv.fsf@x220.int.ebiederm.org>
References: <53A0B617.6070600@candelatech.com>
	<1403044471.16272.20.camel@dcbw.local>
	<53A0CC31.6090707@candelatech.com> <87ha3isdu6.fsf@nemi.mork.no>
	<1403098990.2266.13.camel@dcbw.local>
	<53A1A702.1020300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Williams <dcbw@redhat.com>,
	=?utf-8?Q?Bj=C3=B8rn?= Mork <bjorn@mork.no>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40179 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbaGAVZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 17:25:29 -0400
In-Reply-To: <53A1A702.1020300@candelatech.com> (Ben Greear's message of "Wed,
	18 Jun 2014 07:49:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> After more printk debugging, it seems it is failing to accept the RA due to
> ipv6_chk_addr failing in the ndisc_router_discovery method.
>
> This is probably because one interface on my system is running radvd
> (on one side of a veth pair), and the peer veth is supposed to be
> accepting the ra.
>
> The chk_addr is checking if the source addr for the RA is not found locally, as far
> as I can tell, but in my case, it is local, and it still should be accepted.
>
> My case is a bit special (I'm doing virtual network type things), but
> maybe there is a more useful reason to allow this restriction to be
> relaxed with yet another sysctl?

This is probably long solved by now, but network namespaces solve this
problem very simply.  What is local in one network namespace is not
considered local in another.

Eric
