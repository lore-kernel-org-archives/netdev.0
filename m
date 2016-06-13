From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 13 Jun 2016 21:32:10 +0200
Message-ID: <20160613193208.GA2441@netboy>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Henrik Austad <henrik@austad.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160613130059.GA20320@sisyphus.home.austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 03:00:59PM +0200, Henrik Austad wrote:
> On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> > Which driver is that?
> 
> drivers/net/ethernet/renesas/

That driver is merely a PTP capable MAC driver, nothing more.
Although AVB is in the device name, the driver doesn't implement
anything beyond the PTP bits.
 
> What is the rationale for no new sockets? To avoid cluttering? or do 
> sockets have a drawback I'm not aware of?

The current raw sockets will work just fine.  Again, there should be a
application that sits in between with the network socket and the audio
interface.
 
> Why is configfs wrong?

Because the application will use the already existing network and
audio interfaces to configure the system.

> > Lets take a look at the big picture.  One aspect of TSN is already
> > fully supported, namely the gPTP.  Using the linuxptp user stack and a
> > modern kernel, you have a complete 802.1AS-2011 solution.
> 
> Yes, I thought so, which is also why I have put that to the side and why 
> I'm using ktime_get() for timestamps at the moment. There's also the issue 
> of hooking the time into ALSA/V4L2

So lets get that issue solved before anything else.  It is absolutely
essential for TSN.  Without the synchronization, you are only playing
audio over the network.  We already have software for that.
 
> > 2. A user space audio application that puts it all together, making
> >    use of the services in #1, the linuxptp gPTP service, the ALSA
> >    services, and the network connections.  This program will have all
> >    the knowledge about packet formats, AV encodings, and the local HW
> >    capabilities.  This program cannot yet be written, as we still need
> >    some kernel work in the audio and networking subsystems.
> 
> Why?

Because user space is right place to place the knowledge of the myriad
formats and options.

> the whole point should be to make it as easy for userspace as 
> possible. If you need to tailor each individual media-appliation to use 
> AVB, it is not going to be very useful outside pro-Audio. Sure, there will 
> be challenges, but one key element here should be to *not* require 
> upgrading every single media application.
> 
> Then, back to the suggestion of adding a TSN_SOCKET (which you didn't like, 
> but can we agree on a term "raw interface to TSN", and mode of transport 
> can be defined later? ), was to let those applications that are TSN-aware 
> to do what they need to do, whether it is controlling robots or media 
> streams.

First you say you don't want ot upgrade media applications, but then
you invent a new socket type.  That is a contradiction in terms.

Audio apps already use networking, and they already use the audio
subsystem.  We need to help them get their job done by providing the
missing kernel interfaces.  They don't need extra magic buffering the
kernel.  They already can buffer audio data by themselves.

> > * Kernel Space
> > 
> > 1. Providing frames with a future transmit time.  For normal sockets,
> >    this can be in the CMESG data.  For mmap'ed buffers, we will need a
> >    new format.  (I think Arnd is working on a new layout.)
> 
> Ah, I was unaware of this, both CMESG and mmap buffers.
> 
> What is the accuracy of deferred transmit? If you have a class A stream, 
> you push out a new frame every 125 us, you may end up with 
> accuracy-constraints lower than that if you want to be able to state "send 
> frame X at time Y".

I have no idea what you are asking here.
 
Sorry,
Richard
