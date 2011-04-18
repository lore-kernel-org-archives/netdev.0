From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Suspend/resume - slow resume
Date: Mon, 18 Apr 2011 20:25:36 +0100
Message-ID: <1303154736.2857.46.camel@bwh-desktop>
References: <Pine.SOC.4.64.1104150931390.1320@er3.rutgers.edu>
	 <BANLkTinO+HFq+Mgg1aUz9V==zYs7qSBtDw@mail.gmail.com>
	 <Pine.SOC.4.64.1104151122330.1320@er3.rutgers.edu>
	 <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com>
	 <20110417101731.GA17986@electric-eye.fr.zoreil.com>
	 <BANLkTi=tPc6NmUuTYqbVZduNRNbE=-c34Q@mail.gmail.com>
	 <20110418180813.GA18469@electric-eye.fr.zoreil.com>
	 <BANLkTim_1OgqjCeD1a4Ay2fWJSmPHa_XTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Ciprian Docan <docan@eden.rutgers.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael, J. Wysocki" <rjw@sisk.pl>, Greg KH <gregkh@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9321 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591Ab1DRTZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 15:25:40 -0400
In-Reply-To: <BANLkTim_1OgqjCeD1a4Ay2fWJSmPHa_XTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-18 at 11:49 -0700, Linus Torvalds wrote:
> On Mon, Apr 18, 2011 at 11:08 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > [...]
> >>  - unload not on close, but on device unregister (iow not when you do
> >> "ifconfig eth0 down", but when the "eth0" device really goes away)
> >
> > Without further action, the firmware(s) will thus be locked in until the
> > driver is removed.
> 
> I do agree. It's a downside. Maybe doing it in "close()" is the right
> thing, as long as we don't have that crazy "every four timer ticks"
> situation with rtl8169_reinit_task.
> 
> As mentioned, the only real reason for me to be worried about the
> close thing is that I don't have a good feel for what happens at boot
> time. Are the setup scripts going to look at the interface lots of
> times? On my desktop, I couldn't care less, but I try to keep boot
> time in mind.
>
> Maybe in practice there's just a single open at boot-time (for dhcp or
> whatever), and I'm just worried for no good reason.
[...]

Well, net devices are weird - they don't have file descriptors, they
just have names and indices which you can specify in an ioctl on any
socket (or netlink message on an appropriate netlink socket).  Opening
means starting the device, and I can't think of a configuration tool
that implicitly opens a net device.  Normally they get opened by ifup or
network-manager or the local equivalent, and then they stay open until
an explicit action by the administrator.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

