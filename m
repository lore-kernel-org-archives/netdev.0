From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 00:01:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723000130.3a6a917e.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
	<20030722220745.379a73c6.davem@redhat.com>
	<3F1E1D62.90009@candelatech.com>
	<20030722230215.284dd270.davem@redhat.com>
	<3F1E2A00.5080506@candelatech.com>
	<20030722232719.216d7823.davem@redhat.com>
	<3F1E2CE9.2080404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E2CE9.2080404@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 23:36:25 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I am not writing drivers, I'm trying to write code that works with
> everything that looks remotely like an ethernet device.

Making ethtool interfaces available on every net device is not right,
what about the ISDN folks?  What if they specifically want ethtool
ioctls to fail for their devices?  How can one accomplish that after
your changes?

Answer: You can't.

> I can make this one change and work with ALL drivers, and not have
> to corrupt every friggin driver under the sun.

This is undesirable.  Not all network drivers should implement
ethtool.  A certain family of network devices may not want them,
and we must provide for this.

I don't like your change just as much as I did previously.

> Note it allows me to get a binary representation of the net_device_stats
> w/out having to parse /proc/net/dev or figure out the vast complexity
> of libnetlink.

Whatever tools you write which depend upon this will not work
on any existing 2.4.x kernel, therefore making their utility
basically NIL.

> I have plenty of other things that are currently new ioctls that could
> be handled the same, and thus I could continue to avoid issues with
> other platforms.

What is this "other platform" issue?

If you add anything new, along the lines of SIOCDEVETHTOOl, it's
going to have to go through an entire full review process and in
that review process any necessary 32-bit ioctl translation code
would get added.
