From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 00:34:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723003439.684de751.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
	<20030722220745.379a73c6.davem@redhat.com>
	<3F1E1D62.90009@candelatech.com>
	<20030722230215.284dd270.davem@redhat.com>
	<3F1E2A00.5080506@candelatech.com>
	<20030722232719.216d7823.davem@redhat.com>
	<3F1E2CE9.2080404@candelatech.com>
	<20030723000130.3a6a917e.davem@redhat.com>
	<3F1E391B.80209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E391B.80209@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 00:28:27 -0700
Ben Greear <greearb@candelatech.com> wrote:

> In my case, if the net_device can return net_device_stats, then I want it to work.

This is not for you to decide.  That is the driver author's
choice.

Also, succeeding for _ANY_ ethtool command is going to give
a tool the impression that other basic ethtool commands should
work too.  Your patch makes many devices give very inconsistent
behavior.

> Yes, and since I am ignorant of that stuff, and have no hardware to
> test with, then I want to avoid it.  I can't imagine I'm the
> only one.  Overloading the ethtool ioctl is one way to avoid that pain..adding
> a new, similar ioctl would also work, but seems like duplicated
> effort to me.

The correct "fix" on the 2.4.x side is to add the appropriate ethtool
support to appropriate drivers that lack it and need this interface.
It is not your hack and it is not adding a new ioctl.

You still haven't said why parsing /proc/dev is so bad, and you
even admit that your tool has to fall back to this ANYWAYS.

> Since it seems very unlikly that this sort of patch will be accepted
> in the near future, how _DO_ you want to see new features added that
> require configuration (and reading) from user space?

I just showed you above how to fix this particular problem.  Add
ethtool support to the ethernet device in question, and submit this
change to jgarzik.  It isn't very hard work and things other than your
particular need stand to gain from it.

My final note:  You don't even have the problem you claim to have.
                Use your brain and 'grep' a little bit, ok? :-)

                egrep get_stats net/core/rtnetlink.c

                There it is, exactly what you need and supported on
                every single kernel out there.
