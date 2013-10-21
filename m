From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH] macvlan: resolve ENOENT errors on creation
Date: Mon, 21 Oct 2013 17:54:45 -0400
Message-ID: <20131021215445.GA12034@neilslaptop.think-freely.org>
References: <20131021212801.19330.69659.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41104 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab3JUVy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:54:58 -0400
Content-Disposition: inline
In-Reply-To: <20131021212801.19330.69659.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 02:28:02PM -0700, John Fastabend wrote:
> After the commit below attempting to create macvlan devices was
> resulting in ENOENT errors,
> 
> # ip link add link p3p2 type macvlan
> RTNETLINK answers: Invalid argument
> 
> This happens because netdev_upper_dev_link() is called before
> register_netdevice() in the macvlan code. Through a call chain
> this results in a call to __netdev_adjacent_dev_insert() and
> finally a sysfs_create_link(). This requires the kobject of
> the macvlan to be registered which is done in register_netdevice().
> If there is no kobject which is the case here the ENOENT error
> is seen on the command line.
> 
> To resolve this move the netdev_upper_dev_link() call below
> the register_netdevice() call. This aligns with vlan driver
> flow.
> 
> Regression introduced here,
> 
> commit 5831d66e8097aedfa3bc35941cf265ada2352317
> Author: Veaceslav Falico <vfalico@redhat.com>
> Date:   Wed Sep 25 09:20:32 2013 +0200
> 
>     net: create sysfs symlinks for neighbour devices
> 
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
