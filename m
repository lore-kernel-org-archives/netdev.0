From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 13/23] ptp: igb: convert to the 64 bit
 get/set time methods.
Date: Tue, 31 Mar 2015 23:37:07 +0200
Message-ID: <20150331213707.GA9139@localhost.localdomain>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <67fa71b28f96b222c8027b49efee4144b3754bf7.1427662907.git.richardcochran@gmail.com>
 <1427836090.16312.27.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"baolin.wang@linaro.org" <baolin.wang@linaro.org>,
	"b45643@freescale.com" <b45643@freescale.com>,
	"sshah@solarflare.com" <sshah@solarflare.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"sonic.zhang@analog.com" <sonic.zhang@analog.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"ariel.elior@qlogic.com" <ariel.elior@qlogic.com>,
	"cmetcalf@ezchip.com" <cmetcalf@ezchip.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"arnd@linaro.org" <arnd@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@frees
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427836090.16312.27.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015 at 09:08:10PM +0000, Keller, Jacob E wrote:
> On Sun, 2015-03-29 at 23:12 +0200, Richard Cochran wrote:
> > For the 82576, the driver's clock is implemented using a timecounter,
> > and so with this patch that device is ready for the year 2038.
> > 
> > However, in the case of the i210, the device stores the number of
> > seconds in a 32 bit register.  Therefore, more work is needed on this
> > driver before the year 2038 comes around.
> > 
> > Compile tested only.
> 
> I assume we would want to use a time counter wrapper here to resolve
> this issue?

I would just keep the seconds in software for settime() and adjtime(),
but let the nanoseconds field go to the hardware.  Then, the gettime()
result, the periodic outputs, the external time stamps, and the skb
time stamps will need to be corrected by that many seconds.

Thanks,
Richard
