From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Thu, 16 May 2013 09:24:05 +0300
Message-ID: <20130516062405.GA26548@redhat.com>
References: <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
 <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
 <20121123110146.GC7051@redhat.com>
 <50FE5607.9020405@dlhnet.de>
 <20130123100312.GA8108@redhat.com>
 <5119E9DC.3000505@dlhnet.de>
 <1368541284.15129.317.camel@eboracum.office.bytemark.co.uk>
 <519249F6.3000900@dlhnet.de>
 <1368542949.15129.354.camel@eboracum.office.bytemark.co.uk>
 <1368615603.15129.1471.camel@eboracum.office.bytemark.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Lieven <pl@dlhnet.de>, Stefan Hajnoczi <stefanha@gmail.com>,
	qemu-devel@nongnu.org, netdev@vger.kernel.org
To: Nicholas Thomas <nick@bytemark.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753958Ab3EPGZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 02:25:09 -0400
Content-Disposition: inline
In-Reply-To: <1368615603.15129.1471.camel@eboracum.office.bytemark.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 15, 2013 at 12:00:03PM +0100, Nicholas Thomas wrote:
> Hi again,
> 
> On Tue, 2013-05-14 at 15:49 +0100, Nicholas Thomas wrote:
> > /sys/devices/virtual/net/t100/tun_flags is 0x5002 - so it looks like
> > IFF_ONE_QUEUE was indeed unset by qemu (which is lacking the patch). It
> > surprises me, but that's probably my fault, rather than qemu's.
> 
> 
> I've rebuilt 1.4.1 with the IFF_ONE_QUEUE patch and tun_flags is now
> 0x7002; unfortunately, I'm still seeing this bug, twice in five trials.
> Symptoms in `ifconfig t100` now differ; overruns stays at 0, and
> "dropped" increases monotonically as I send packets. Those packets do
> appear if I tcpdump t100 on the host, but not if I tcpdump t100 on the
> guest.
> 
> I've turned off gro in the guest, which makes no difference, and tried
> changing the queue sizes (post-hoc) in both guest and host, in the hope
> of causing them to be emptied out, clearing the condition; again to no
> effect.
> 
> The VMs in question are bridged to a large (and busy) VLAN with no
> ingress filtering to speak of; I guess what's happening is that the
> transmit queue is filled up by that traffic while the guest is in ipxe,
> and it never gets out of that state when it happens... so maybe there is
> still an underlying problem?
> 
> /Nick


Is this with or without vhost-net in host?

-- 
MST
