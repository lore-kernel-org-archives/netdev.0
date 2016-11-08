From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v3 3/4] ptp_clock: allow for it to be optional
Date: Tue, 8 Nov 2016 13:10:26 +0000
Message-ID: <cc41f1f3-1bc8-1835-1bf1-2d342768e49d@solarflare.com>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
 <1478556899-2951-4-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        <netdev@vger.kernel.org>, <linux-kbuild@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478556899-2951-4-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/16 22:14, Nicolas Pitre wrote:
> In order to break the hard dependency between the PTP clock subsystem and
> ethernet drivers capable of being clock providers, this patch provides
> simple PTP stub functions to allow linkage of those drivers into the
> kernel even when the PTP subsystem is configured out. Drivers must be
> ready to accept NULL from ptp_clock_register() in that case.
>
> And to make it possible for PTP to be configured out, the select statement
> in those driver's Kconfig menu entries is converted to the new "imply"
> statement. This way the PTP subsystem may have Kconfig dependencies of
> its own, such as POSIX_TIMERS, without having to make those ethernet
> drivers unavailable if POSIX timers are cconfigured out. And when support
> for POSIX timers is selected again then the default config option for PTP
> clock support will automatically be adjusted accordingly.
>
> The pch_gbe driver is a bit special as it relies on extra code in
> drivers/ptp/ptp_pch.c. Therefore we let the make process descend into
> drivers/ptp/ even if PTP_1588_CLOCK is unselected.
>
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> Acked-by: Richard Cochran <richardcochran@gmail.com>
For the sfc change:
Acked-by: Edward Cree <ecree@solarflare.com>

And I accept that "suggests" isn't needed and the current "imply" semantics
are probably fine.  If not we can always change it or resurrect "suggests".
