From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in shutdown)
 on 3.3-rc1
Date: Tue, 28 Feb 2012 18:58:36 -0600
Message-ID: <1330477116.2822.191.camel@dabdike.int.hansenpartnership.com>
References: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
	 <qCQH7HfZS8E.A.x6F.98rRPB@chimera>
	 <1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
	 <20120228233225.GA1322@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120228233225.GA1322-+O+RPeR0w/SWJtbYL5oUVDJtLkR7yuzc@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-02-28 at 15:32 -0800, Matt Carlson wrote:
> On Mon, Feb 27, 2012 at 05:44:34PM -0600, James Bottomley wrote:
> > On Thu, 2012-02-23 at 23:55 +0100, Rafael J. Wysocki wrote:
> > > This message has been generated automatically as a part of a summary report
> > > of recent regressions.
> > > 
> > > The following bug entry is on the current list of known regressions
> > > from 3.2.  Please verify if it still should be listed and let the tracking team
> > > know (either way).
> > > 
> > > 
> > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=42707
> > > Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc1
> > > Submitter	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> > > Date		: 2012-01-28 19:56 (27 days old)
> > > Message-ID	: <1327780565.2924.24.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
> > > References	: http://marc.info/?l=linux-kernel&m=132778076214873&w=2
> > 
> > Still present in 3.3-rc4; I've bisected it back to this commit:
> > 
> > commit 92feeabf3f673767c6ee4cfc7fc224098446c1c1
> > Author: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > Date:   Thu Dec 8 14:40:14 2011 +0000
> > 
> >     tg3: Save stats across chip resets
> > 
> > and sure enough, just reverting this single commit on 3.3-rc4 fixes the
> > problem.
> > 
> > James
> 
> Are you dealing with a bcm5700 or bcm5701 device?

Yes, this is it:

20:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Hewlett-Packard Company Core Lan 1000Base-T
	Flags: bus master, 66MHz, medium devsel, latency 128, IRQ 72
	Memory at ffffffff90000000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] PCI-X non-bridge device
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
	Kernel driver in use: tg3

>   If so, can you try
> the following patch?
> 
> Subject: [PATCH 1/1] tg3: Fix tg3_get_stats64 for 5700 / 5701 devs

Well, the patch needs some attention:

  CC [M]  drivers/net/ethernet/broadcom/tg3.o
drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_get_estats':
drivers/net/ethernet/broadcom/tg3.c:9882: warning: 'return' with a value, in function returning void

It also didn't apply incredibly well (the fuzz factors and line offsets
are a lot higher than they should be):

patching file drivers/net/ethernet/broadcom/tg3.c
Hunk #1 succeeded at 7886 (offset -115 lines).
Hunk #2 succeeded at 7908 (offset -115 lines).
Hunk #3 succeeded at 9845 (offset -278 lines).
Hunk #4 succeeded at 9854 (offset -278 lines).
Hunk #5 succeeded at 9873 (offset -278 lines).
Hunk #6 succeeded at 9958 (offset -275 lines).
Hunk #7 succeeded at 10007 with fuzz 1 (offset -275 lines).
Hunk #8 succeeded at 10103 with fuzz 2 (offset -2096 lines).

but it seems to work.

Thanks,

James
