From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: network interface *name* alias support?
Date: Tue, 27 May 2008 14:03:52 -0500
Message-ID: <20080527190352.GE25696@auslistsprd01.us.dell.com>
References: <48387B18.2090300@trash.net> <alpine.LNX.1.10.0805242254020.19084@fbirervta.pbzchgretzou.qr> <4838D7E4.7050401@trash.net> <20080525.051713.124717485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de, dwmw2@infradead.org,
	jchapman@katalix.com, jonathan@jonmasters.org, tgraf@suug.ch,
	rick.jones2@hp.com, auke-jan.h.kok@intel.com,
	johnathan@jonmasters.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:47087 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757138AbYE0TFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 15:05:11 -0400
Content-Disposition: inline
In-Reply-To: <20080525.051713.124717485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2008 at 05:17:13AM -0700, David Miller wrote:
> Physical geography information for a device is available
> to userspace already.  If tools want to present that to
> the user in a suitable interface, fine.  But what is
> being proposed here is not necessary to implement that.

OK, I'm just trying to understand how you would see this "feature"
being implemented in userspace.  Advice welcome.

I keep looking at my analogue: disk devices.

Disks have a hard-coded association: Some device node with number
(8,0) means "the first SCSI disk device" to the kernel.  Regardless of
what the name of the file that implements the device node is (probably
/dev/sda, but not necessarily), or if there are symlinks pointing at
that file.  The kernel only cares about the linkage between the device
node and the driver that accepts read/write/ioctl/etc. to it.

Network devices have no such thing that I can tell.  I get at the
device names (as presently assigned) by reading /proc/net/dev (I'd be
happy to be told of a more correct way - this is what net-tools uses.)
The moment I've finished reading this though, another process can come
along and change these devices names.  Now every ioctl() my code makes
could fail because the name (in struct ifreq) is the handle used for
such calls.  One could argue it's a rare thing to change device
names...

This still leaves us the problem of wanting perhaps several naming
policies: by logical use, by physical geography, by kernel enumeration
name, etc.  Every tool that interacts with device names would need to
be modified to get at these "new names" to make use of them,
which are then translated (in userspace) to the current matching
kernel name, which is then used to make the ioctl() calls.  And we'll
have to persist these "new names" (assuming they aren't always
computable - e.g. the udev persistent net names rules today -
certainly we'd have to do that for any logical use naming policy; 
agreed the persistance mapping would have to exist in userspace).

Something like that?

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
