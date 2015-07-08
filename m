From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2 1/1] Added additional callback to ptp_clock_info:
Date: Wed, 8 Jul 2015 07:17:37 -0500
Message-ID: <20150708121737.GN25028@jcartwri.amer.corp.natinst.com>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
 <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
 <20150706204458.GE25028@jcartwri.amer.corp.natinst.com>
 <20150708115434.GA17012@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708115434.GA17012@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 08, 2015 at 01:54:34PM +0200, Richard Cochran wrote:
> On Mon, Jul 06, 2015 at 03:44:58PM -0500, Josh Cartwright wrote:
> > It's difficult to make too many judgements without seeing how a driver
> > might implement this; is there another patchset that shows how a driver
> > implements this?
> 
> The interface is certainly clear enough to me.  The details of
> obtaining a cross time stamp from the hardware will remain hidden
> behind the interface in any case.

It's unusual to see interfaces added like this without also seeing users
at the same time to see how the pieces fit together.  Should I have
assumed this was a PATCH RFC for just the API?

I'm afraid this is the tip of a much larger iceberg.  If a device is
doing hardware crosstimestamping, what is the hardwares view of this
"system clock"?  How is it tied into the kernels' timekeeping?  How is
it ensured that same clock the hardware sees is the kernel's actively
selected clocksource?

You get this for free in software with getnstimeofday(), by pushing it
to hardware, the boundaries of responsibilities are all
unclear...without seeing the whole picture.

> > > -	int rsv[14];   /* Reserved for future use. */
> > > +	/* Whether the clock supports precise system-device cross timestamps */
> > > +	int precise_timestamping;
> >
> > Perhaps now is a good time to add an unsigned int 'flags' member instead,
> > and start allocating bits.
>
> Considering the rate of growth for the PHC stuff, I am not worried
> about spending a whole 'int' on this.

Fair enough!

Thanks,

  Josh
