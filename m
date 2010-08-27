From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 14:03:41 +0200
Message-ID: <201008271403.41949.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<1282594899.3111.358.camel@localhost.localdomain>
	<20100827110855.GA11657@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100827110855.GA11657-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 27 August 2010, Richard Cochran wrote:
> On Mon, Aug 23, 2010 at 01:21:39PM -0700, john stultz wrote:
> > On Thu, 2010-08-19 at 17:38 +0200, Richard Cochran wrote:
> > > On Thu, Aug 19, 2010 at 02:28:04PM +0200, Arnd Bergmann wrote:
> > > > Have you considered passing a struct timex instead of ppb and ts?
> > > 
> > > Yes, but the timex is not suitable, IMHO.
> > 
> > Could you expand on this?
> 
> We need to able to specify that the call is for a PTP clock. We could
> add that to the modes flag, like this:
> 
> /*timex.h*/
> #define ADJ_PTP_0 0x10000
> #define ADJ_PTP_1 0x20000
> #define ADJ_PTP_2 0x30000
> #define ADJ_PTP_3 0x40000
>
> I can live with this, if everyone else can, too.

My suggestion was actually to have a new syscall with the existing
structure, and pass a clockid_t value to it, similar to your
sys_clock_adjtime(), not change the actual sys_adjtime syscall.
  
> > Could we not add a adjustment mode ADJ_SETOFFSET or something that would
> > provide the instantaneous offset correction?
> 
> Yes, but we would also need to add a struct timespec to the struct
> timex, in order to get nanosecond resolution. I think it would be
> possible to do in the padding at the end?

Yes, that's exactly what the padding is for. Instead of timespec, you can
probably have a extra values for replacing the existing ppm values with
ppb values.

	Arnd
