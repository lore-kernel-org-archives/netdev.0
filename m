From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net interfaces
Date: Thu, 29 Oct 2009 08:11:25 -0500
Message-ID: <20091029131125.GA13809@auslistsprd01.us.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 09:23:57AM +0100, Kay Sievers wrote:
> On Tue, Oct 27, 2009 at 21:55, Matt Domsch <Matt_Domsch@dell.com> wrote:
> > On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
> >> Here's a proof of concept to further the discussion..
> >>
> >> The default filename uses the format:
> >> ?? /dev/netdev/by-ifindex/$ifindex
> >>
> >> This provides the infrastructure to permit udev rules to create aliases for
> >> network devices using symlinks, for example:
> >>
> >> ?? /dev/netdev/by-name/eth0 -> ../by-ifindex/1
> >> ?? /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
> >>
> >> A library (such as the proposed libnetdevname) could use this information
> >> to provide an alias->realname mapping for network utilities.
>
> That all sounds very much like something which will hit us back some
> day. I'm not sure, if udev should publish such dead text files in
> /dev, it does not seem to fit the usual APIs/assumptions where /sys
> and /dev match, and libudev provides access to both.

While we could do this without any kernel changes at all, it does
still leave unresolved the concern of the in-kernel users of
netdevice-by-name - everything that uses dev_get_by_name(), and any
userspace tool that doesn't get converted to use the netdevice-by-path
concept.

Which brings us back to still looking for options.

Multiple names for the same device gives us a way out.
Users of the ethX naming convention continue unchanged, and live
with the nondeterminism; Users of other naming conventions can get
names that work for them, with needed determinism.

Netdev team - are you in agreement that having multiple names to
address the same netdevice is a worthwhile thing to add, to allow a
variety of naming schemes to exist simultaneously?  If not, this whole
discussion will be moot, and my basic problem, that the ethX naming
convention is nondeterministic, but we need determinism, remains
unresolved.

Assuming we agree it's worthwhile, I'm open to ideas for ways to solve
it.  We've proposed char devices for udev to manage, and fixing up
userspace programs, but that doesn't solve in-kernel users by name.
Dann proposed another method (above) which Kay isn't fond of, and
which has the same drawback.  I need another option then.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
