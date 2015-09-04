From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Fri, 4 Sep 2015 15:02:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509041438520.15006@nanos>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com> <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com> <alpine.DEB.2.11.1508222143530.3873@nanos> <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Sep 2015, Hall, Christopher S wrote:

Can you please teach your mail client to add proper line breaks around
80? Your mail renders horrible in a text based mail client.

> In addition to the network interface, ART will be used in the audio
> interface as well.  We need to support the case where an audio
> co-processor will control the audio device.  In this case, the
> get_ts() function supplied by the audio driver will be very slow
> (several milliseconds) and the result will be out of date by some
> fraction of that amount.

You are not telling at all, what this driver is supposed to do, what
this get_ts() function is for and how that co-processor thing works.

You just make claims, that you need this without explaining WHY. And
that WHY is the most interesting part.

> This loop makes strict requirements on the latency and recency. Is
> it possible to relax that requirement in some way?

No. This function is explicitely for the precise timestamp usecase,
which is required by PTP and other sane use cases.

> For example, supply the ART value as an argument and, in the case of
> the realtime clock, keep a short history of clock changes.  It would

It's not only clock realtime which is affected by those.

> fail in cases where there are a lot of calls to adjtimex(),

That has nothing to do with lots of adjtimex calls. The kernel does a
slow correction of the conversion values itself to avoid time jumping
around.

> but it will would work most of the time.

Will, would, most? - Could, perhaps, sometimes?

Looks like a design from the trainwreck engineering departement. We
want to have it very precise, but we don't care if it behaves like a
random number generator.

Can you folks please get your act together and provide coherent
explanations about the usecase and the constraints instead of
proposing random functions with obscure semantics?

Thanks,

	tglx
