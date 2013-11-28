From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH openvswitch] netlink: Implement & enable memory
 mapped netlink i/o
Date: Thu, 28 Nov 2013 11:24:49 -0800
Message-ID: <20131128192449.GA28279@nicira.com>
References: <2336aeee25d64eab89302c28c33b7cb7d1a55560.1385057738.git.tgraf@redhat.com>
 <20131125230253.GR1435@nicira.com>
 <52967768.8090308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, fleitner@redhat.com,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:54675 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751045Ab3K1TYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 14:24:54 -0500
Received: by mail-yh0-f45.google.com with SMTP id v1so5173867yhn.18
        for <netdev@vger.kernel.org>; Thu, 28 Nov 2013 11:24:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52967768.8090308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 27, 2013 at 11:51:20PM +0100, Thomas Graf wrote:
> On 11/26/2013 12:02 AM, Ben Pfaff wrote:
> >On Thu, Nov 21, 2013 at 07:16:54PM +0100, Thomas Graf wrote:
> >>Based on the initial patch by Cong Wang posted a couple of months
> >>ago.
> >>
> >>This is the user space counterpart needed for the kernel patch
> >>'[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'
> >>
> >>Allows the kernel to construct Netlink messages on memory mapped
> >>buffers and thus avoids copying. The functionality is enabled on
> >>sockets used for unicast traffic.
> >>
> >>Further optimizations are possible by avoiding the copy into the
> >>ofpbuf after reading.
> >>
> >>Cc: Cong Wang <xiyou.wangcong@gmail.com>
> >>Signed-off-by: Thomas Graf <tgraf@redhat.com>
> >
> >Does this depend on other patches or some specific Linux kernel
> >headers?  It doesn't build here on GCC (similar results with Clang):
> 
> Yes, it depends on a sufficiently recent <linux/netlink.h>. We can
> either #ifdef the mmap code or we provide a local copy of
> <linux/netlink.h> in include/linux. The code automatically falls back if
> the kernel does not support NL MMAP so that seems superior.

Can you add the new definitions to the end of lib/netlink-protocol.h,
conditional on their being needed?  We already have a number of
compatibility definitions there.
