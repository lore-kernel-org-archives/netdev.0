From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Possible race with br_del_if()
Date: Thu, 18 Aug 2005 15:35:31 -0700
Message-ID: <20050818153531.61f62ac0@dxpl.pdx.osdl.net>
References: <20050818214036.GH10593@us.ibm.com>
	<20050818151202.6fe6ded4@dxpl.pdx.osdl.net>
	<20050818222323.GI10593@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ryan Harper <ryanh@us.ibm.com>
In-Reply-To: <20050818222323.GI10593@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Aug 2005 17:23:23 -0500
Ryan Harper <ryanh@us.ibm.com> wrote:

> * Stephen Hemminger <shemminger@osdl.org> [2005-08-18 17:11]:
> > On Thu, 18 Aug 2005 16:40:36 -0500
> > Ryan Harper <ryanh@us.ibm.com> wrote:
> > 
> > > Hello,
> > > 
> > > I've encountered several oops when adding and removing interfaces from
> > > bridges while using Xen.  Most of the details are available [1]here.
> > > The short of it is the following sequence:
> > 
> > Doesn't the mutex in RTNL work right?  or are you calling
> > routines with out asserting it?
> 
> unregister_netdevice asserts RTNL, add_del_if() in br_ioctl.c doesn't
> seem to do so.  I don't see it down dev_get_by_index() path either.  It
> looks like any caller of add_del_if() isn't asserting RTNL.  The two
> callers I see are:
> 
> br_dev_ioctl() in br_ioctl.c
> old_dev_ioctl() in br_ioctl.c

But the pat to br_dev_ioctl() is via the socket ioctl and that
should already have gotten RTNL.


dev_ioctl
	rtnl_lock()
	dev_ifsioc()
		dev->do_ioctl --> br_dev_ioctl

			
