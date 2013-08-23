From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [Bridge] Can linux kernel bridge forward 802.1q tagged vlan
 packets?
Date: Fri, 23 Aug 2013 06:22:34 +0200
Message-ID: <20130823062234.c34a6da6.skraw@ithnet.com>
References: <20130822224453.ca93782f.skraw@ithnet.com>
	<20130822234941.4affc863@catus>
	<20130822151941.301cd36a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marek Kierdelewicz <marek@piasta.pl>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-a02.ithnet.com ([217.64.83.97]:48652 "HELO ithnet.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753610Ab3HWEWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 00:22:38 -0400
In-Reply-To: <20130822151941.301cd36a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Aug 2013 15:19:41 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Thu, 22 Aug 2013 23:49:41 +0200
> Marek Kierdelewicz <marek@piasta.pl> wrote:
> 
> > Hi,
> > 
> > >My general idea is to bridge tagged vlan packets from a physical
> > >interface (intel) to a virtual interface (virtio in qemu) and not
> > >losing the tags, so the qemu guest can use vconfig and friends to get
> > >some vlan interfaces. Is this possible and are there any additional
> > >steps necessary besides the usual bridge configuration?
> > 
> > I'm using this setup with KVM virtualization (Qemu's successor). It
> > didn't work with default nic type for guest (realtek I think) as 802.1q
> > tags were not preserved properly in one of the directions. I don't
> > remember specifics. Anyway using e1000 driver instead of default fixed
> > it. Works like a charm.
> 
> KVM e1000 Vnic doesn't do VLAN offloading at least in my experience.
> Virtio works fine.

Ok guys, here is one of the major questions in this issue:

How did you manage to convince the _host_ interface driver (in my setup "igb"
from intel) to get the vlan tagged packets from the LAN port. igb has a vlan
filter function built in and reads _no_ tagged packets at all if the driver
does not tell it to. And in case of "up-ing" the interface for attachment to a
bridge it does not configure this vlan filter.
How is this expected to work?

-- 
Regards,
Stephan
