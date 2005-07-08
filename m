From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Fri, 8 Jul 2005 14:14:54 -0700
Message-ID: <Pine.CYG.4.58.0507081352390.1980@mawilli1-desk2.amr.corp.intel.com>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
 <20050702081346.GA20789@kroah.com> <Pine.CYG.4.58.0507061138030.1208@mawilli1-desk2.amr.corp.intel.com>
 <20050706195232.GB18359@kroah.com> <20050707142544.GA9418@tuxdriver.com>
 <Pine.CYG.4.58.0507071511300.3956@mawilli1-desk2.amr.corp.intel.com>
 <20050707231451.GA936@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        "John W. Linville" <linville@tuxdriver.com>,
        Radheka Godse <radheka.godse@intel.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
        netdev@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20050707231451.GA936@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(Adding vger to Cc: list, so as to spread the joy around.)

On Thu, 7 Jul 2005, Greg KH wrote:

> >
> > Moving the individual bond directories to a bonds/ directory
> > is problematic.  Because each bond shows up a just another network
> > interface, they show up in /sys/class/net automatically.  We'd have to
> > make a bunch of changes to the device model to account for bonding, and
> > we'd break the semantics of the /sys/class/net hierarchy.
>
> Why not just put them in /sys/class/bond/ instead?
As Aaron Brown noted in another reply, it's inappropriate for bonding to
do this.  Bonding is really just another network driver, and its
interfaces show up in /sys/class/net courtesy of the device model.  We
don't need to replicate this capability; we just need to extend it a bit.

Adding /sys/class/bond/ would cause a much larger protest that what we're
dealing with now (i.e. pretty much only you).


> > reading of Documentation/filesystems/sysfs.txt indicates that such a usage
> > is "socially acceptable".  (Or at least it was to Patrick Mochel back in
> > January of 2003.)
>
> Pat was just trying to be nice.  I'm not.  :)

Well, if "nice" isn't the policy any more, then the doc needs to change.

> Just don't make them readable.  Lots of sysfs files are write only.

OK, you got me there.  I did some poking and you are absolutely correct.

However, I did a little more poking, and found a bunch of files that have
more than one item in them.  HW resource listings, block device scheduling
stuff, plenty of examples.  Are they socially acceptable?


> > bonding_masters.  This currently is a problem, since sysfs itself does not
> > handle appends properly.
>
> Because you are not supposed to do that.

Sysfs will happily accept O_APPEND opens, and will happily report success
on seek attempts, although neither operation is permitted.  Whether or not
you're supposed to, this behavior is just plain wrong.
