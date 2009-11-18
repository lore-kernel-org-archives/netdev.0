From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH iproute2] ip: Add support for setting MAC and VLAN
 on hardware queues
Date: Wed, 18 Nov 2009 11:15:55 -0800
Message-ID: <20091118111555.0e4caa8f@nehalam>
References: <20091117215432.15195.94504.stgit@localhost.localdomain>
	<20091117140641.7f8c8ac0@nehalam>
	<20091118.100728.91511216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, mitch.a.williams@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39114 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489AbZKRTQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 14:16:20 -0500
In-Reply-To: <20091118.100728.91511216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Nov 2009 10:07:28 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 17 Nov 2009 14:06:41 -0800
> 
> > On Tue, 17 Nov 2009 13:55:07 -0800
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > 
> >> From: Williams, Mitch A <mitch.a.williams@intel.com>
> >> 
> >> This patch adds support to the "ip" tool for setting the MAC address and
> >> VLAN filter for hardware device queues. This is most immediately useful for
> >> SR-IOV; for VF devices to be usable in the real world, the hypervisor or VM
> >> manager must be able to set these parameters before the VF device is
> >> assigned to any VM.
> >> 
> >> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> >> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > Is there anything to avoid prevent this from being misused by users who
> > are doing multiqueue. Maybe we need equivalent of "mounted" flag that block
> > devices have?
> 
> It's a privileged config operation as far as I can tell.
> 
> Given that, what could we possibly need to protect?
> 
> This stuff looks basically fine to me.
> 

I was thinking that maybe the general question of SR-IOV overlap with other
multiqueue usage. How is it possible to be sure queue is not being used
for other traffic?  The MAC stuff itself is fine, just an example where
changing a queue being used for SR-IOV makes sense, but if being used
for regular multiqueue receive doesn't.

The filesystem example is that for years it was possible to do something
dumb like do fsck on a mounted filesystem and cause trouble (on unix and early
linux); but current systems don't allow it because it is stupid idea.

-- 
