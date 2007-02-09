From: Greg KH <greg@kroah.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Fri, 9 Feb 2007 08:48:07 -0800
Message-ID: <20070209164807.GD5356@kroah.com>
References: <200702080400.l1840lFd002314@hera.kernel.org> <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com> <20070209005601.GE30794@kroah.com> <200702082259.47685.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Dmitry Torokhov <dtor@insightbb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:60123 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946667AbXBIQt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 11:49:27 -0500
Content-Disposition: inline
In-Reply-To: <200702082259.47685.dtor@insightbb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 10:59:46PM -0500, Dmitry Torokhov wrote:
> On Thursday 08 February 2007 19:56, Greg KH wrote:
> > On Thu, Feb 08, 2007 at 12:29:12PM -0500, Dmitry Torokhov wrote:
> > > On 2/8/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > >On Thu, 08 Feb 2007 07:43:18 -0500
> > > >Jeff Garzik <jeff@garzik.org> wrote:
> > > >
> > > >> Linux Kernel Mailing List wrote:
> > > >> > Gitweb:     
> > > >http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=43cb76d91ee85f579a69d42bc8efc08bac560278
> > > >> > Commit:     43cb76d91ee85f579a69d42bc8efc08bac560278
> > > >> > Parent:     2943ecf2ed32632473c06f1975db47a7aa98c10f
> > > >> > Author:     Greg Kroah-Hartman <gregkh@suse.de>
> > > >> > AuthorDate: Tue Apr 9 12:14:34 2002 -0700
> > > >> > Committer:  Greg Kroah-Hartman <gregkh@suse.de>
> > > >> > CommitDate: Wed Feb 7 10:37:11 2007 -0800
> > > >> >
> > > >> >     Network: convert network devices to use struct device instead of 
> > > >class_device
> > > >> >
> > > >> >     This lets the network core have the ability to handle 
> > > >suspend/resume
> > > >> >     issues, if it wants to.
> > > >
> > > >It fixes a non-problem. I would like to see the network core suspend/resume
> > > >proposal as well. Last time I examined doing network core suspend help,
> > > >the problem was that the physical device suspend was called before the
> > > >class device. It is not clear how this change would help.
> > > 
> > > If physical devices are registered before class devices then when
> > > suspending class devices are naturally suspended first. It is still
> > > not clear to me why we need to convert everythign to struct device, I
> > > believe I've shown (with patches) that it is possible to integrate
> > > struct class_device into PM framework and avoid reshuffling half of
> > > the kernel code.
> > 
> > I don't want to have two separate device trees in the kernel (well, one
> > big device tree and a bunch of little class_device trees.)  The code
> > duplication in the class_device code is just too much, and I get
> > questions all the time as to what the differences are.
> >
> 
> While duplication of code is a real concern my worry is constant fattening
> of struct device. For example most physical devices do not interface
> directly with userspace but every single one of them now has dev_t.
> Former class_devices do not need suspend/resume early framework either.
> And so on, and so forth.

The memory requirements of 'struct device' is trivial in the overall
system requirements.

Now this doesn't mean we need to go crazy with adding everything and the
kitchen sink to the structure, but adding a dev_t is not going to make
any difference to anyone.

thanks,

greg k-h
