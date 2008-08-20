From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 07:38:22 +0200
Message-ID: <1219210702.7591.280.camel@violet.holtmann.net>
References: <20080819.140458.236030589.davem@davemloft.net>
	 <200808192315.48718.rjw@sisk.pl>
	 <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
	 <20080819.143556.245692295.davem@davemloft.net>
	 <1219206013.7591.227.camel@violet.holtmann.net>
	 <alpine.DEB.1.10.0808192138260.12859@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	rjw@sisk.pl, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756244AbYHTFie@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0808192138260.12859@asgard.lang.hm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> >> And then there is the Bluetooth SCO change which I agree was
> >> borderline and I should have pushed back on.
> >
> > so this is the statement, I sent Dave to explain why that change was in
> > there:
> >
> > ---
> > For the btusb driver this adds the promised SCO support. The btusb
> > driver is a new driver and will eventually replace hci_usb. Adding SCO
> > support was the last missing piece. All distributions are using the
> > hci_usb driver at the moment and you can only select one of them. So
> > this can't introduce any regression. With this change the distributions
> > are now able to select the new driver if they really want to.
> > ---
> >
> > Was this absolutely needed after -rc3. Of course not. No questions asked
> > about it. So why did it ended up in there?
> >
> > Almost everybody is using the hci_usb driver and that one has issues
> > that are beyond fixable. So the btusb is its replacement and with this
> > change it became a real alternate solution. For me this is a new driver
> > that would allow people to use it in case hci_usb gives them a hard time
> > and falls over again. And fixing hci_usb is not an option. A lot of
> > people tried it and they failed. I think the last one was Pavel a month
> > ago. This is why I re-wrote the whole beast from scratch.
> >
> > So that is my excuse why I thought this would be good choice to push it
> > to Dave. No more excuses and no new drivers after the merge window. At
> > least not from me.
> 
> one of thr goals of the new release approach was to make releases 
> frequently enough that it's not a big deal to miss a merge window, you 
> only have to wait a couple of months (rather then a couple of years under 
> the old model).
> 
> while I don't see a bit problem with drivers going in for previously 
> unsupported hardware (at least since I custom compile my kernels with all 
> unnessasary drivers disabled, so I wouldn't even try to compile them ;-) 
> it doesn't hurt much, either as a user, or for you as a developer (as you 
> note above) to go ahead and delay till the next merge window.

the downside is that users wanna use this hardware have to wait for the
next kernel release. The -next and -mm trees are simply not for
everybody. Even some of the -rc kernels are a pain if you happen to use
a non-x86 system. The kernel developers can fix them easily or know who
to ask for a fix. So decision to include certain driver updates or new
drivers are made from the perspective of the end users.

>From a developer perspective if you work on a well separated subsystem
or an individual driver, I can go for many kernel releases without
running into major merge conflicts.

We do have the fast moving targets like wireless. And it is not always
the developers fault. The hardware manufactures are putting out new
chips so fast nowadays that keeping up with the drivers is a hard job.
Also laptop/desktop manufactures are a lot quicker in integrating these
chips and bringing them to market.

I made the EeePC 901 example. A 2.6.26 kernel has no support for the
Ethernet card in it. This happened that last time with a 2.2 kernel
where I bought an Ethernet card that was not supported.

So when it comes to new driver support, it is a judgment call. Some
times we make the wrong one.

Regards

Marcel
