From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 5 Aug 2012 00:23:20 +0300
Message-ID: <CAJZOPZJ=WPXcEysh-2p+pmY7RJME24zySWHGzGYbOq9LKidvBA@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ali@mellanox.com, ebiederm@xmission.com, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35790 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HDVXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 17:23:21 -0400
Received: by ghrr11 with SMTP id r11so1748380ghr.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 14:23:21 -0700 (PDT)
In-Reply-To: <20120803.163627.1867181085116225405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 4, 2012 at 2:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Ali Ayoub <ali@mellanox.com>
> Date: Fri, 03 Aug 2012 15:39:36 -0700

>> Users would like to use sockets API from the VM without re-writing their
>> applications on top of IB verbs, this driver meant to allow such a user
>> to do so.

> That's what IPoIB was for, the application writers who don't want to have
> to be knowledgable about IB verbs.
>
> You're messing with the link layer here, and that's what is upsetting me.
>
> It's a complete cop-out to changing the VM tools and emulators properly to
> handle a new link layer.
>
> The applications writers already have a way to use IB whilst using
> something familiar, like IPv4, via IPoIB.  You're doing something
> completely different here, and it stinks.


Dave,

Just quick recap of things to make sure we're in sync on the facts
here and (me) trying to better follow your arguments:

Bringing IB to app usage is done through the IB verbs / RDMA CM, which
is supported
for quite a long while for native mode and BTW as for SRIOV, there's a
now running patch set @ linux-rdma submitted to Roland
http://marc.info/?l=linux-rdma&m=134398354428293&w=2

IPoIB is meant to allow IP apps to use IB, defined by IETF spec (RFC 4391/4392)

The idea in eIPoIB was to allow IP apps running on VMs under a
Para-Virtual set of mind, e.g when the Linux PV networking stack comes
into play, to use that stack w.o modifying it.

When looking on that, we thought so far so good, and went in the way
posted here. If reusing your last sentence... this driver provides a
way for apps to use the PV stack AND IB whilst using something
familiar, like IPv4.


I'd like to better understand your "messing with the link layer here,
and that's what is upsetting" claim --- since the service here is IP,
and this service has well defined mechanisms, eIPoIB is basically a
shim layer that allows to provide this service for VMs that interacts
with the emulators, drivers and tools used in Linux and the related
guest OS PV drivers (virtio and friends). For example, that messing
mostly goes down to translating ARP requests/replies from being
carried in Ethernet frame to be carried in IPoIB packet, is that
really too hacky? why and what?

Or.
