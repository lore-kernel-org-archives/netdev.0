From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/5] net: hwmon fixes
Date: Tue, 26 Nov 2013 20:08:30 +0000
Message-ID: <1385496510.1586.63.camel@bwh-desktop.uk.level5networks.com>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>
	<5290E0B9.1030606@roeck-us.net>
	<1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
	<52938D67.2000401@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nithin
	Nayak Sujir <nsujir@broadcom.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, lm-sensors@lm-sensors.org,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52938D67.2000401@roeck-us.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2013-11-25 at 09:48 -0800, Guenter Roeck wrote:
> On 11/25/2013 09:15 AM, Ben Hutchings wrote:
> > On Sat, 2013-11-23 at 09:07 -0800, Guenter Roeck wrote:
> >> On 11/23/2013 08:48 AM, Ben Hutchings wrote:
> >>> On Fri, 2013-11-22 at 22:07 -0800, Guenter Roeck wrote:
> >>>> The hwmon subsystem is used by various network drivers to report temperature
> >>>> sensor and other information. Unfortunately, its use is often not correct.
> >>>> Typical errors are that the mandatory name sysfs attribute is not created,
> >>>> that the temperature sensor index starts with 0 instead of 1, and/or that
> >>>> sysfs attributes are created after the hwmon device was created.
> >>>
> >>> As it happens, I was just looking at what we do in sfc
> >>> (drivers/net/ethernet/sfc/mcdi_mon.c) and wondering why I made it create
> >>> the hwmon device before the attributes.  I think I avoided the other
> >>> bugs though.
> >>>
> >> Hi Ben,
> >>
> >> Yes, I know about that one. It concluded that it would be too invasive
> >> and risky to try to fix it without access to hardware to test the results.
> >> That is why I said "fixes _most_ of the problems".
> >>
> >> As for why the attributes are created after registration, it was most likely
> >> because there was no API available to attach the sysfs attributes to
> >> the hwmon device in a clean way. The new APIs fix that.
> >
> > We don't attach them to the hwmon device either, and I would rather not
> > change that yet because lm-sensors 2 is still widely used.
> >
> 
> Hmm .. then there should be no good reason to create the attributes
> only after hwmon registration.
>
> As for lm-sensors 2 ... really ? Seems odd that people would use the
> latest kernel with 5+ years old versions of applications / libraries.
> but I guess the world is full of such oddities, so maybe I should not
> be surprised.
[...]

As Jean pointed out, the net drivers implementing hwmon aren't supported
by lm-sensors 2 anyway.  So we should go ahead and use the new API in
sfc.  I've opened an internal bug report for this, but it is likely to
be low priority for the team.  But if you write a patch I can test it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349351&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
