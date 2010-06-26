From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: dhclient, checksum and tap
Date: Sun, 27 Jun 2010 00:14:19 +0300
Message-ID: <20100626211419.GA3646@redhat.com>
References: <20100625151008.GA17911@redhat.com> <20100625.112152.241921019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert.xu@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753668Ab0FZVTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jun 2010 17:19:22 -0400
Content-Disposition: inline
In-Reply-To: <20100625.112152.241921019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 25, 2010 at 11:21:52AM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 25 Jun 2010 18:10:08 +0300
> 
> > I've been looking at the issue of checksum on
> > dhcp packets: to recap, 8dc4194474159660d7f37c495e3fc3f10d0db8cc
> > added a way for af_packet sockets to get the packet status.
> > Unfortunately not all dhcp clients caught up with
> > this development, so they are still broken
> > when both server and client run on the same host,
> > e.g. with bridge+tap.
> > 
> > And of course virtualization adds another way to run
> > old dhcp clients, so userspace virtio net in qemu has
> > a hack to detect DHCP and fill in the checksum.
> > I guess we could add this in vhost, as well.
> > 
> > However, one wonders whether the tap driver is a better place
> > for this work-around, that would help all users.
> > Any objections against putting such code in tap?
> 
> We added the af_packet status as the migration path to deal with
> this issue in the cleanest manner possible.  Putting a new hack
> into the TAP driver works contrary to that goal.

Hmm, problem is, using the af_packets status requires
userspace changes, and so does not help old clients.
And for virt, clients might be running old kernels without this support.
qemu has a hack to make old guests running within qemu work.
I guess I can copy that hack into vhost - a bit ugly as I don't have
access to the original skb there, so I will have to duplcate some logic,
but doable.  Is this what you suggest?  OTOH if we had the workaround in
tap, this could replace hacks in both vhost and qemu.

-- 
MST
