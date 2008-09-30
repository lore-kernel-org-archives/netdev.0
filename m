From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [Bug 11442] btusb suspend/resume bug...
Date: Tue, 30 Sep 2008 07:55:40 +0200
Message-ID: <1222754141.1825.55.camel@violet.holtmann.net>
References: <20080916.155123.181085856.davem@davemloft.net>
	 <200809222342.46735.rjw@sisk.pl>
	 <8C4643EC-E6D9-47D3-8A27-04A2B3CDC6CC@holtmann.org>
	 <200809271541.15963.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200809271541.15963.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rafael,

> > >> Rafael, can you pull from my tree and test the changes:
> > >>
> > >> git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/ 
> > >> bluetooth-2.6.git
> > >>
> > >> It would be interesting if these fixes are enough.
> > >
> > > They appear to be enough.  I haven't had any suspend/resume failures  
> > > with them
> > > applied.
> > 
> > so it works _without_ applying patch-btusb-suspend.
> 
> Well, unfortunately I spoke too soon.
> 
> I'm still seeing post-hibernation crashes triggered by the bluetooth user land
> trying to use the device handled by btusb.  They happen every second
> hibernation, more or less, and apparently they are oopses in various code
> paths not directly related to bluetooth, like ext3 (memory corruption or
> what?).

I pushed two extra patches to my bluetooth-2.6 repository:

git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

One is fixing a double-free in the error path. This error path can be
triggered during suspend/resume if the USB core just disconnects the
device. Please check if that fixes it for you.

> With patch-btusb-suspend applied I don't see them (actually I have to use
> a slightly modified version of the patch which is appended).
> 
> Interestingly enough, suspend to RAM works without any visible problems.

As Oliver said, the USB core should do the right thing when no suspend
and resume callbacks are provided. I looked through the code so many
times now and I am running out of ideas what can happen.

Lets try it one last time without the suspend patch, but the double free
fix and see if that works. Otherwise I really give up.

Regards

Marcel
