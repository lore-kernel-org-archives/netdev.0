From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next V3 1/2] igb: add PTP Hardware
	Clock code
Date: Wed, 11 Jan 2012 17:14:43 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580267C2@ORSMSX105.amr.corp.intel.com>
References: <cover.1325964581.git.richardcochran@gmail.com>
	<06a2d33bed05d5c17c03fca6f0fcc2fe3f6870f4.1325964581.git.richardcochran@gmail.com>
	<02874ECE860811409154E81DA85FBB5801E86F@ORSMSX106.amr.corp.intel.com>
	<20120110084450.GA5356@cherladcori01>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>, John Stultz <john.stultz@linaro.org>,
	Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120110084450.GA5356@cherladcori01>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Tuesday, January 10, 2012 12:45 AM
> To: Keller, Jacob E
> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Kirsher,
> Jeffrey T; Ronciak, John; John Stultz; Thomas Gleixner
> Subject: Re: [PATCH net-next V3 1/2] igb: add PTP Hardware Clock code
> 
> On Mon, Jan 09, 2012 at 05:42:20PM +0000, Keller, Jacob E wrote:
> 
> > Is there a reason for not using the timecounter structure from the
> > kernel? It is a layer beneath the timecompare code which is meant to
> > handle this condition. As far as I can tell this issue is solved in
> > the timecounter code. If it is not, then that should be a bug in the
> > timecounter cyclecounter code. I don't know if this issue occurs in
> > the timecounter structure because it handles the ns conversion
> > differently.
> 
> My only reason is that I am not sure that the timecounter code really
> does what we need.  It might well work.  Consider, though, that the
> 82580 register does not overflow in the usual way. The upper 24 bits
> are always zero.
> 
> What I wrote does the right thing, I think.  However, duplicated
> effort is always bad, so can you show me how to change it?
> 
Sure :) The way to set it up also includes the ability to specify width, so that for example the 82580 can be set to the bit length, and you provide the whole cycle counter value as a 40bit value.

I will send you a copy of the code I will be using for the ixgbe driver.

It *does* handle the conversion in a different way, because it doesn't keep an overflow counter, instead it converts "cycles" to nanoseconds. However, it claims to have support for past timestamps as long as they are within half the cycle max value.

Basically it's a portion of the code used in the timecompare stuff, but without the timecompare averaging scheme which is bad. I don't use the structure the same way that the older igb code did (because it does funky things with the 82580 and doesn't setup the other devices correctly for clock rate adjustment)

> Thanks,
> Richard


------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
