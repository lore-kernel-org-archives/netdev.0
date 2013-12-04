From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Wed, 4 Dec 2013 08:33:28 -0800
Message-ID: <20131204163328.GE30874@nicira.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:35059 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755623Ab3LDQde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 11:33:34 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so23797666pbc.38
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 08:33:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 03, 2013 at 12:19:02PM +0100, Thomas Graf wrote:
> Based on the initial patch by Cong Wang posted a couple of months
> ago.
> 
> This is the user space counterpart needed for the kernel patch
> '[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'
> 
> Allows the kernel to construct Netlink messages on memory mapped
> buffers and thus avoids copying. The functionality is enabled on
> sockets used for unicast traffic.
> 
> Further optimizations are possible by avoiding the copy into the
> ofpbuf after reading.
> 
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

If I'm doing the calculations correctly, this mmaps 8 MB per ring-based
Netlink socket on a system with 4 kB pages.  OVS currently creates one
Netlink socket for each datapath port.  With 1000 ports (a moderate
number; we sometimes test with more), that is 8 GB of address space.  On
a 32-bit architecture that is impossible.  On a 64-bit architecture it
is possible but it may reserve an actual 8 GB of RAM: OVS often runs
with mlockall() since it is something of a soft real-time system (users
don't want their packet delivery delayed to page data back in).

Do you have any thoughts about this issue?
