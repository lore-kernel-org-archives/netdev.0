From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Wed, 21 Mar 2012 13:02:38 -0400
Message-ID: <CAAsGZS4xU6Uqu59r6donnVmvi-NdxhQRi-7FEEHwg0mFcmKhxA@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321160817.GB1941@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org,
	jacob.e.keller@intel.com, tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120321160817.GB1941@netboy.at.omicron.at>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 12:08 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Wed, Mar 21, 2012 at 11:00:59AM -0400, chetan loke wrote:
>>
>> Once PHC->gettime goes live(aka exported to user space), we can't
>> really control how users will use it in their applications. There
>> could be 100+ apps all trying to get real-time from the network to do
>> some time-keeping stuff. They might pound the ioctls at high rate. The
>> last thing we would want is to self-induce a light weight DOS.
>
> Well, if people want to write programs that make no sense at all,
> then I can cannot stop them. There really isn't any point in general
> applications using the PHC directly. You can easily synchronize the

I thought the core patches enables using PHC as a reference time, no?
So that seems to be contradicting the PHC API. If there's no point
then why are we exporting PHC->get_time as a generic interface? May be
just limit get_time interface to something like ethtool?


> system time to the PHC to within a few microseconds. Just the error
> from reading the clock (due to various kinds of latency) is much
> larger than that.
>

Once, the clocks are in-sync, it's not an error - but  *somewhat
fixed* latency. There are users who don't want to spend extra money
for expensive GPS time-sync stuff but yet have enough CPUs such that
they can dedicate 1 CPU for book-keeping. For such users, this
*somewhat fixed* latency should be constant over a period of time even
when other CPUs are processing traffic at line rate.


> Also, although you might be able to optimize clock_gettime performance
> for a PCI card, this will never work for PHY based devices, which, by
> the way, offer superior PTP time stamping. So, in general, applications
> should stick to reading the system time. We still need to get some more tools out there in order to support the
> PHC->system synchronization, but that is not too far off. That is what
> I am working on now,

Sounds good on the tools part. But if applications should stick to
reading sys-time then either we shouldn't export the API or export it
selectively.If there's an API then user-space guys will use it. For
this discussion, lets focus on PCI cards because that is what this
patch talks about. Also the majority of the deployment will be LOM or
PCI cards.


>
> Thanks,
> Richard
>
thanks
Chetan

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
