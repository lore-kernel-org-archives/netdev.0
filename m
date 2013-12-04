From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Wed, 04 Dec 2013 18:20:53 +0100
Message-ID: <529F6475.3090903@redhat.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com> <20131204163328.GE30874@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932708Ab3LDRVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 12:21:23 -0500
In-Reply-To: <20131204163328.GE30874@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 05:33 PM, Ben Pfaff wrote:
> If I'm doing the calculations correctly, this mmaps 8 MB per ring-based
> Netlink socket on a system with 4 kB pages.  OVS currently creates one
> Netlink socket for each datapath port.  With 1000 ports (a moderate
> number; we sometimes test with more), that is 8 GB of address space.  On
> a 32-bit architecture that is impossible.  On a 64-bit architecture it
> is possible but it may reserve an actual 8 GB of RAM: OVS often runs
> with mlockall() since it is something of a soft real-time system (users
> don't want their packet delivery delayed to page data back in).
>
> Do you have any thoughts about this issue?

That's certainly a problem. I had the impression that the changes that
allow to consolidate multiple bridges to a single DP would minimize the
number of DPs used.

How about we limit the number of mmaped sockets to a configurable
maximum that defaults to 16 or 32?
