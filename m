From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 15:33:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616223316.GA29618@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D0BD5B.201@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 05:36:27PM -0400, Jeff Garzik wrote:
> 
> This is something on which we'll have to agree to disagree.
> 
> In Linux we are free to improve the APIs :)

	Well, this is where I wish system apps were strongly linked
with the kernel as it is the case in *BSD. They don't have the
headacke of backward/forward compatibility that we have.

> >	I also asked Jeff why he want to redesign the API, and in the
> >end there was only two issues :
> >	1) type-safe handler versus generic handler. I personally
> >disagree with Jeff on that one. But, you can easilly fix it by
> >offering wrapper to the current API :
> >	http://marc.theaimsgroup.com/?l=linux-netdev&m=107896289630224&w=2
> 
> I think I explained myself better, in the recent post in this thread. 
> Such a wrapper does nothing to move the locking, ioctl marshalling, and 
> security checks out of the drivers.

	The iw_handler already take care of the net locking, security
check, and most of the ioctl marshalling. What the driver has to take
care is only the remaining of marshalling and driver locking.

	I think you did not understood my idea at all.
	If you build a set of generic wrappers and hook them in the
iw_handler table, you could trivially add the features you feel are
missing into those wrappers. Those wrappers would expose whatever API
you choose to the driver, call your struct wireless_ops for example.

> >	2) The use of ioctls. I've created a patch to add RtNetlink
> >support to the Wireless Extension API, and so far nobody has commented
> >on this :
> >	http://marc.theaimsgroup.com/?l=linux-netdev&m=107846135617655&w=2
> >	A more recent/functional version of this patch is on my web
> >page. I'm not going to waste time on this if nobody cares.
> 
> Well, I liked the patch at least :)

	Ok, I'll try to resume work on that, after I manage WPA. I
still have issues with the RtNetlink API which was not designed to
perform individual GET requests, and this make the code a bit
tricky. I also want to totally remove the useless pointer from this
API, but need a way to do that transparently.

> 	Jeff

	Have fun...

	Jean
