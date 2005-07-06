From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Wed, 6 Jul 2005 12:02:02 -0700
Message-ID: <20050706120202.6a048b14@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
	<200507020030.03635.dtor_core@ameritech.net>
	<Pine.CYG.4.58.0507061126090.1208@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor_core@ameritech.net>, netdev@oss.sgi.com,
        Radheka
 Godse <radheka.godse@intel.com>, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0507061126090.1208@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Jul 2005 11:37:49 -0700
Mitch Williams <mitch.a.williams@intel.com> wrote:

> 
> 
> On Sat, 2 Jul 2005, Dmitry Torokhov wrote:
> 
> >
> > Couple of comments:
> [snip]
> 
> > > +
> > > +static struct class *netdev_class;
> > > +/*--------------------------- Data Structures -----------------------------*/
> > > +
> > > +/* Bonding sysfs lock.  Why can't we just use the subsytem lock?
> > > + * Because kobject_register tries to acquire the subsystem lock.  If
> > > + * we already hold the lock (which we would if the user was creating
> > > + * a new bond through the sysfs interface), we deadlock.
> > > + */
> > > +
> > > +struct rw_semaphore bonding_rwsem;
> >
> > klists were just added to the kernel proper. Does this sentiment still
> > holds true?
> 
> 
> Thanks for reviewing this patch, Dmitry.  We appreciate your efforts, and
> we'll make the changes you pointed out.
> 
> In this case, we hold the lock on access to all bonding-owned sysfs files,
> because it's possible for changes to one file to alter the contents and/or
> presence of another file.  Consider:
> 
> 1) process 'foo' opens /sys/class/net/bond1/mode
> 2) process 'bar' opens /sys/class/net/bonding_masters
> 3) process 'bar' writes to bonding_masters and removes bond1
> 4) process 'foo' tries to write
> 5) Boom.  Or rather, oops.
> 
> Thus, we have this lock.  I don't think that klists will help here.

You need to use kobject ref counting then, not the semaphore.
