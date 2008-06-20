From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Fri, 20 Jun 2008 08:41:31 -0700
Message-ID: <20080620084131.3313abe8@speedy>
References: <200806201037.46687.Bircoph@list.ru>
	<84144f020806200412s5e0225eblbb2001ca139e7fdc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Andrew Savchenko" <Bircoph@list.ru>, linux-kernel@vger.kernel.org,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	shemminger@vyatta.com, "Jeff Garzik" <jeff@garzik.org>,
	sorbica@icplus.com.tw, "Jesse Huang" <jesse@icplus.com.tw>
To: "Pekka Enberg" <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58699 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbYFTPlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:41:21 -0400
In-Reply-To: <84144f020806200412s5e0225eblbb2001ca139e7fdc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008 14:12:51 +0300
"Pekka Enberg" <penberg@cs.helsinki.fi> wrote:

> Hi Andrew,
> 
> (Please don't trim the cc.)
> 
> On Fri, Jun 20, 2008 at 9:37 AM, Andrew Savchenko <Bircoph@list.ru> wrote:
> > Hello,
> >
> > On Wed, 27 Feb 2008 09:44:44 +0200 (EET), Pekka J Enberg wrote:
> >> Stephen Hemminger wrote:
> >> > > Please don't do this as a config option. Config options seem
> >> > > like a good idea to developers but are difficult for
> >> > > distributions.  Either support jumbo frames by default or
> >> > > not at all.
> >>
> >> On Tue, 26 Feb 2008, Jeff Garzik wrote:
> >> > Agreed, but to be more specific... always compile in jumbo
> >> > frame support. You don't have to enable it at runtime by
> >> > default, though.
> >>
> >> Ok, so a sysfs attribute would be sufficient, I suppose? I don't
> >> have the hardware though, so I don't even know if the jumbo
> >> frame code actually works at this point hence the RFC. So I'll
> >> wait for someone to test this before sending a new patch. Thanks
> >> for the review!
> >
> > I own such card:
> > 02:02.0 Ethernet controller: Sundance Technology Inc / IC Plus Corp
> > IP1000 Family Gigabit Ethernet (rev 41)
> > and I use patch similar to yours in order to enable Jumbo Frames.
> > See attachment for details, patch is done for linux-2.6.25.6.
> >
> > It works fine for me. However, I enabled 10K jumbo boxes instead of
> > default 4K value, activated using your patch. Reason is simple: I
> > need at least 9000-byte jumbo boxes in my network.
> >
> > However, I have one request for you: please, make in possible to
> > choose max MTU via kernel config option. In different environments
> > different people may need different max MTU sizes (2K...10K).
> > Recommended value is 4K (as described in the original driver from
> > manufacturer, which was remake into kernel's one), but, for
> > example, I'm interested in larger MTU values. OTOH larger MTU
> > values require more memory and so on. For me, as for end user of
> > Linux kernel, a possibility to select desired max MTU is very
> > attractive and is definitely in no doubt more convenient than
> > patching the kernel myself each time.
> >
> > So, feel free to add jumbo boxes on ipg support to the mainstream
> > and, please, make in possible to select max MTU; 4K as default
> > will be fine.
> 
> As I don't have the hardware, I would appreciate if you could test
> the following quilt tree:
> 
>   http://www.kernel.org/pub/linux/kernel/people/penberg/patches/ipg/2.6.26-rc6/
> 
> [Note: in case you're not familiar with quilt, the patches need to
>  be applied in the order specified by the quilt 'series' file
>  included there.]
> 
> You can enable 10KB jumbo frames either by passing:
> 
>   ipg.jumbo=10k
> 
> to the kernel command line or, alternatively, load the ipg module
> as follows:
> 
>   modprobe ipg jumbo=10k
> 
> You cannot enable or disable jumbo frame support once the module
> is loaded so if you want to try out different frame sizes, you
> first need to unload the module.
> 
>                            Pekka

The code should enable/disable anything it needs based on the MTU size
in the change_mtu call. If the driver needs to reallocate buffers, change receiver
settings, make sacrifices to deities, or phone home that is the place to do it.
In other words no compile or config option fro MTU settings please.
