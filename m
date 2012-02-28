From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in
 shutdown) on 3.3-rc1
Date: Tue, 28 Feb 2012 16:07:20 -0500 (EST)
Message-ID: <20120228.160720.990486775074267929.davem@davemloft.net>
References: <qCQH7HfZS8E.A.x6F.98rRPB@chimera>
	<1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
	<20120228012408.GA29622@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120228012408.GA29622-+O+RPeR0w/SWJtbYL5oUVDJtLkR7yuzc@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Mon, 27 Feb 2012 17:24:08 -0800

> On Mon, Feb 27, 2012 at 05:44:34PM -0600, James Bottomley wrote:
>> On Thu, 2012-02-23 at 23:55 +0100, Rafael J. Wysocki wrote:
>> > This message has been generated automatically as a part of a summary report
>> > of recent regressions.
>> > 
>> > The following bug entry is on the current list of known regressions
>> > from 3.2.  Please verify if it still should be listed and let the tracking team
>> > know (either way).
>> > 
>> > 
>> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=42707
>> > Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc1
>> > Submitter	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
>> > Date		: 2012-01-28 19:56 (27 days old)
>> > Message-ID	: <1327780565.2924.24.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
>> > References	: http://marc.info/?l=linux-kernel&m=132778076214873&w=2
>> 
>> Still present in 3.3-rc4; I've bisected it back to this commit:
>> 
>> commit 92feeabf3f673767c6ee4cfc7fc224098446c1c1
>> Author: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Date:   Thu Dec 8 14:40:14 2011 +0000
>> 
>>     tg3: Save stats across chip resets
>> 
>> and sure enough, just reverting this single commit on 3.3-rc4 fixes the
>> problem.
>> 
>> James
> 
> I don't see anything incorrect about the patch.  I'm guessing the patch
> just changes the timing somehow.
> 
> tg3_reset_chip() does not take any driver-internal spinlocks.  That
> happens at tg3_close().  I'm guessing the spinlock in the trace is coming
> from synchronize_irq().

If you can't figure it out, we need to revert, so send me a revert patch
as soon as possible.
