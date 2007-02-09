From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Thu, 8 Feb 2007 22:59:46 -0500
Message-ID: <200702082259.47685.dtor@insightbb.com>
References: <200702080400.l1840lFd002314@hera.kernel.org> <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com> <20070209005601.GE30794@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:25972 "EHLO
	asav01.insightbb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946091AbXBIEfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 23:35:04 -0500
In-Reply-To: <20070209005601.GE30794@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 February 2007 19:56, Greg KH wrote:
> On Thu, Feb 08, 2007 at 12:29:12PM -0500, Dmitry Torokhov wrote:
> > On 2/8/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > >On Thu, 08 Feb 2007 07:43:18 -0500
> > >Jeff Garzik <jeff@garzik.org> wrote:
> > >
> > >> Linux Kernel Mailing List wrote:
> > >> > Gitweb:     
> > >http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=43cb76d91ee85f579a69d42bc8efc08bac560278
> > >> > Commit:     43cb76d91ee85f579a69d42bc8efc08bac560278
> > >> > Parent:     2943ecf2ed32632473c06f1975db47a7aa98c10f
> > >> > Author:     Greg Kroah-Hartman <gregkh@suse.de>
> > >> > AuthorDate: Tue Apr 9 12:14:34 2002 -0700
> > >> > Committer:  Greg Kroah-Hartman <gregkh@suse.de>
> > >> > CommitDate: Wed Feb 7 10:37:11 2007 -0800
> > >> >
> > >> >     Network: convert network devices to use struct device instead of 
> > >class_device
> > >> >
> > >> >     This lets the network core have the ability to handle 
> > >suspend/resume
> > >> >     issues, if it wants to.
> > >
> > >It fixes a non-problem. I would like to see the network core suspend/resume
> > >proposal as well. Last time I examined doing network core suspend help,
> > >the problem was that the physical device suspend was called before the
> > >class device. It is not clear how this change would help.
> > 
> > If physical devices are registered before class devices then when
> > suspending class devices are naturally suspended first. It is still
> > not clear to me why we need to convert everythign to struct device, I
> > believe I've shown (with patches) that it is possible to integrate
> > struct class_device into PM framework and avoid reshuffling half of
> > the kernel code.
> 
> I don't want to have two separate device trees in the kernel (well, one
> big device tree and a bunch of little class_device trees.)  The code
> duplication in the class_device code is just too much, and I get
> questions all the time as to what the differences are.
>

While duplication of code is a real concern my worry is constant fattening
of struct device. For example most physical devices do not interface
directly with userspace but every single one of them now has dev_t.
Former class_devices do not need suspend/resume early framework either.
And so on, and so forth.
 
> With these slow and gradual changes, we are getting a true, unified,
> device tree, and it will reduce the amount of code and complexity we
> need to maintain and fix in the driver core itself.
> 
> And it should also alow for proper power management functionality, using
> the changes that Linus put into the driver core about 8 months ago.
> 
> Don't worry, I have input patches queued up next for you Dmitry :)
> 

;)

-- 
Dmitry
