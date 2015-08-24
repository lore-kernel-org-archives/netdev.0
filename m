From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH v3 3/4] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Mon, 24 Aug 2015 20:16:51 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A90AD3C6@ORSMSX109.amr.corp.intel.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-4-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222226540.3873@nanos> <20150822211718.GA8561@netboy>
 <alpine.DEB.2.11.1508231011360.3873@nanos>
 <20150823112556.GA8569@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: 'Richard Cochran' <richardcochran@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150823112556.GA8569@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Sunday, August 23, 2015 4:26 AM
> To: Thomas Gleixner
> Cc: Hall, Christopher S; Kirsher, Jeffrey T; hpa@zytor.com;
> mingo@redhat.com; john.stultz@linaro.org; x86@kernel.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; intel-wired-
> lan@lists.osuosl.org; peterz@infradead.org
> Subject: Re: [PATCH v3 3/4] Add support for driver cross-timestamp to
> PTP_SYS_OFFSET ioctl
> 
> On Sun, Aug 23, 2015 at 10:15:00AM +0200, Thomas Gleixner wrote:
> > So why can't you take N samples from the synced hardware? It does not
> > make any sense to me to switch to the imprecise mode if nsamples > 1.
> 
> Ok, then I prefer to leave this "imprecise" method in place and ...
> 
> > You can also provide a new IOCTL PTP_SYS_OFFSET_PRECISE which returns
> > -ENOSYS if hardware timestamping is not available and avoid the whole
> > nsamples dance for the case where we can get precise timestamps.
> 
> have this for the new way.
> 
> By keeping the imprecise method, we will be able to run both methods
> on the new hardware.  That will help to quantify how imprecise the old
> method is.

This means: remove code changes from the PTP_SYS_OFFSET ioctl and call getsynctime64() from a new ioctl PTP_SYS_OFFSET_PRECISE.  Right?

And use the same type (struct ptp_sys_offset) for the new ioctl?  Or should a new simplified struct be used? Such as:

struct precise_ptp_sys_offset {
	struct ptp_clock_time device;
	struct ptp_clock_time system;
};

Does it make sense to keep the "cross-timestamp" capabilities flag as-is?

> 
> Thanks,
> Richard
