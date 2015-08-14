From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 4/4] Added getsynctime64() callback
Date: Fri, 14 Aug 2015 08:32:51 +0200
Message-ID: <20150814063250.GB18603@localhost.localdomain>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
 <1438988495-9942-5-git-send-email-christopher.s.hall@intel.com>
 <20150810084949.GA18566@localhost.localdomain>
 <B79D786B7111A34A8CF09F833429C493A90A0E74@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A90A0E74@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 09:10:36PM +0000, Hall, Christopher S wrote:
> > > +	if (!cpu_has_art)
> > > +		return -EOPNOTSUPP;
> > 
> > Perform this check before registration, setting .getsynctime64
> > accordingly.
> 
> The problem here is that ART initialization doesn't happen until we
> install TSC as a clocksource.  This design is per Thomas'
> suggestion.  That occurs after the driver is loaded (as a module).

So that 'cpu_has_art' actually means 'cpu_has_art_and_has_been_initialized'?

In any case, returning EOPNOTSUPP early on, but OK later seems mean to
me.  If the clocks aren't ready yet, the error should be EBUSY so that
user space knows it can try again.

Thanks,
Richard
