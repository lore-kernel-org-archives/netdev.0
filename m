From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Thu, 22 Mar 2012 08:09:01 +0100
Message-ID: <20120322070900.GD2182@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321160817.GB1941@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6CC@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	chetan loke <loke.chetan@gmail.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580DA6CC@ORSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 05:06:09PM +0000, Keller, Jacob E wrote:
> 
> I agree with Chetan. I think it would be best to make sure the
> correct form of locking is done, as we are providing an interface to
> the user. Using a seqlock would allow for preventing the ioctls from
> blocking the hardware timestamp code.

Okay, you can improve the time stamping path in the driver to avoid
contending with callers to clock_gettime. But that will not help the
hundreds of clock_gettime callers from contending with each other.

> It's a fairly simple change for the gettime function (the most
> likely culprit to be hammered) by changing it to use
> timecounter_cyc2time function instead of timecounter_read. (as long
> as timecounter_read is called at least every 1/2 the system time
> overflow, which it should be due to the work task.)
>
> With that change, then the section use a seqlock (along with the
> section for checking hardware timestamps). Other places would do the
> full write lock.

So, you think that clock_gettime should not read the card's time
registers?

Richard



------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
