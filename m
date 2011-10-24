From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Qemu-devel] [RFC v2 PATCH 5/4 PATCH] virtio-net: send
 gratuitous packet when needed
Date: Mon, 24 Oct 2011 11:11:05 +0200
Message-ID: <1319447465.31243.15.camel@deadeye>
References: <20111022054311.21798.3340.stgit@dhcp-8-146.nay.redhat.com>
	 <87ty6z10f8.fsf@rustcorp.com.au> <20111024052526.GA2362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>, <aliguori@us.ibm.com>,
	<quintela@redhat.com>, <jan.kiszka@siemens.com>,
	<qemu-devel@nongnu.org>, <blauwirbel@gmail.com>,
	<pbonzini@redhat.com>, <kvm@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25123 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1JXJLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 05:11:32 -0400
In-Reply-To: <20111024052526.GA2362@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-24 at 07:25 +0200, Michael S. Tsirkin wrote:
> On Mon, Oct 24, 2011 at 02:54:59PM +1030, Rusty Russell wrote:
> > On Sat, 22 Oct 2011 13:43:11 +0800, Jason Wang <jasowang@redhat.com> wrote:
> > > This make let virtio-net driver can send gratituous packet by a new
> > > config bit - VIRTIO_NET_S_ANNOUNCE in each config update
> > > interrupt. When this bit is set by backend, the driver would schedule
> > > a workqueue to send gratituous packet through NETDEV_NOTIFY_PEERS.
> > > 
> > > This feature is negotiated through bit VIRTIO_NET_F_GUEST_ANNOUNCE.
> > > 
> > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > 
> > This seems like a huge layering violation.  Imagine this in real
> > hardware, for example.
> 
> commits 06c4648d46d1b757d6b9591a86810be79818b60c
> and 99606477a5888b0ead0284fecb13417b1da8e3af
> document the need for this:
> 
> NETDEV_NOTIFY_PEERS notifier indicates that a device moved to a 
> different physical link.
> 	and
> In real hardware such notifications are only
> generated when the device comes up or the address changes.
> 
> So hypervisor could get the same behaviour by sending link up/down
> events, this is just an optimization so guest won't do
> unecessary stuff like try to reconfigure an IP address.
> 
> 
> Maybe LOCATION_CHANGE would be a better name?
[...]

We also use this in bonding failover, where the system location doesn't
change but a different link is used.  However, I do recognise that the
name ought to indicate what kind of change happened and not what the
expected action is.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
