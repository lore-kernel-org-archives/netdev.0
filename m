From: dann frazier <dannf@hp.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Wed, 28 Oct 2009 09:09:13 -0600
Message-ID: <20091028150913.GB3612@ldl.fc.hp.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091028130308.GA24611@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091028130308.GA24611@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 08:03:08AM -0500, Matt Domsch wrote:
> On Wed, Oct 28, 2009 at 09:23:57AM +0100, Kay Sievers wrote:
[...]
> > That all sounds very much like something which will hit us back some
> > day. I'm not sure, if udev should publish such dead text files in
> > /dev, it does not seem to fit the usual APIs/assumptions where /sys
> > and /dev match, and libudev provides access to both. It all sounds
> > more like a database for a possible netdevname library, which does not
> > need to be public in /dev, right?
> 
> Right, it doesn't need to be in /dev.  We could have udev rules that
> simply call yet another program to maintain that database, in yet
> another way.

Or have udev maintain them in a private directory (e.g.,
/var/lib/udev/netalias). Personally, I like the approach of having
udev manage them as files - its an abstraction our users already get,
and they don't have to learn two mechanisms when aliasing disks and
nics (SYMLINK ftw). Plus there's obviously a lot of code reuse to be
had (most of my patch was moving code into a common section).

If we want to hide the file implementation - we could invent another
udev construct that basically aliases SYMLINK (e.g. NETALIAS) that
works iff the device is a netdevice. That would let us switch out
implementations in the future, but would obviously be much more
invasive.

-- 
dann frazier

