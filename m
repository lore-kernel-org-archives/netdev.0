From: David Miller <davem@davemloft.net>
Subject: Re: dhclient, checksum and tap
Date: Fri, 25 Jun 2010 11:21:52 -0700 (PDT)
Message-ID: <20100625.112152.241921019.davem@davemloft.net>
References: <20100625151008.GA17911@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert.xu@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016Ab0FYSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 14:21:39 -0400
In-Reply-To: <20100625151008.GA17911@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 25 Jun 2010 18:10:08 +0300

> I've been looking at the issue of checksum on
> dhcp packets: to recap, 8dc4194474159660d7f37c495e3fc3f10d0db8cc
> added a way for af_packet sockets to get the packet status.
> Unfortunately not all dhcp clients caught up with
> this development, so they are still broken
> when both server and client run on the same host,
> e.g. with bridge+tap.
> 
> And of course virtualization adds another way to run
> old dhcp clients, so userspace virtio net in qemu has
> a hack to detect DHCP and fill in the checksum.
> I guess we could add this in vhost, as well.
> 
> However, one wonders whether the tap driver is a better place
> for this work-around, that would help all users.
> Any objections against putting such code in tap?

We added the af_packet status as the migration path to deal with
this issue in the cleanest manner possible.  Putting a new hack
into the TAP driver works contrary to that goal.
