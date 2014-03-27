From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v2 1/3] xen-netback: remove pointless clause from if
 statement
Date: Thu, 27 Mar 2014 14:38:28 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029CBF7@AMSPEX01CL01.citrite.net>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
 <1395924973-42904-2-git-send-email-paul.durrant@citrix.com>
 <289461862.20140327144546@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net>
 <68689563.20140327150256@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net>
 <675566283.20140327152917@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:59177 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbaC0Oia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:38:30 -0400
In-Reply-To: <675566283.20140327152917@eikelenboom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> Sent: 27 March 2014 14:29
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei Liu
> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause from if
> statement
> 
> 
> Thursday, March 27, 2014, 3:09:32 PM, you wrote:
> 
> >> -----Original Message-----
> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> Sent: 27 March 2014 14:03
> >> To: Paul Durrant
> >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei
> Liu
> >> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause
> from if
> >> statement
> >>
> >>
> >> Thursday, March 27, 2014, 2:54:46 PM, you wrote:
> >>
> >> >> -----Original Message-----
> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> >> Sent: 27 March 2014 13:46
> >> >> To: Paul Durrant
> >> >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell;
> Wei
> >> Liu
> >> >> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause
> >> from if
> >> >> statement
> >> >>
> >> >>
> >> >> Thursday, March 27, 2014, 1:56:11 PM, you wrote:
> >> >>
> >> >> > This patch removes a test in start_new_rx_buffer() that checks
> whether
> >> >> > a copy operation is less than MAX_BUFFER_OFFSET in length, since
> >> >> > MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller
> of
> >> >> > start_new_rx_buffer() already limits copy operations to PAGE_SIZE
> or
> >> less.
> >> >>
> >> >> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> >> >> > Cc: Ian Campbell <ian.campbell@citrix.com>
> >> >> > Cc: Wei Liu <wei.liu2@citrix.com>
> >> >> > Cc: Sander Eikelenboom <linux@eikelenboom.it>
> >> >> > ---
> >> >>
> >> >> > v2:
> >> >> >  - Add BUG_ON() as suggested by Ian Campbell
> >> >>
> >> >> >  drivers/net/xen-netback/netback.c |    4 ++--
> >> >> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >> >>
> >> >> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> >> >> netback/netback.c
> >> >> > index 438d0c0..72314c7 100644
> >> >> > --- a/drivers/net/xen-netback/netback.c
> >> >> > +++ b/drivers/net/xen-netback/netback.c
> >> >> > @@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset,
> >> >> unsigned long size, int head)
> >> >> >          * into multiple copies tend to give large frags their
> >> >> >          * own buffers as before.
> >> >> >          */
> >> >> > -       if ((offset + size > MAX_BUFFER_OFFSET) &&
> >> >> > -           (size <= MAX_BUFFER_OFFSET) && offset && !head)
> >> >> > +       BUG_ON(size > MAX_BUFFER_OFFSET);
> >> >> > +       if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
> >> >> >                 return true;
> >> >> >
> >> >> >         return false;
> >> >>
> >> >> Hi Paul,
> >> >>
> >> >> Unfortunately .. no good ..
> >> >>
> >> >> With these patches (v2) applied to 3.14-rc8 it all seems to work well,
> >> >> until i do my test case .. it still chokes and now effectively permanently
> >> stalls
> >> >> network traffic to that guest.
> >> >>
> >> >> No error messages or anything in either xl dmesg or dmesg on the host
> ..
> >> and
> >> >> nothing in dmesg in the guest either.
> >> >>
> >> >> But in the guest the TX bytes ifconfig reports for eth0 still increase but
> RX
> >> >> bytes does nothing, so it seems only the RX path is effected)
> >> >>
> >>
> >> > But you're not getting ring overflow, right? So that suggests this series is
> >> working and you're now hitting another problem? I don't see how these
> >> patches could directly cause the new behaviour you're seeing.
> >>
> >> Don't know  .. how ever .. i previously tested:
> >>         - unconditionally doing "max_slots_needed + 1"  in "net_rx_action()",
> >> and that circumvented the problem reliably without causing anything else
> >>         - reverting the calculation of "max_slots_needed + 1"  in
> >> "net_rx_action()" to what it was before :
> >>                 int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> >>                 if (vif->can_sg || vif->gso_mask || vif->gso_prefix_mask)
> >>                         max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> >>
> 
> > So, it may be that the worse-case estimate is now too bad. In the case
> where it's failing for you it would be nice to know what the estimate was.
> Looking at netfront, we could be in trouble if it ever goes above 64.
> 
> It probaly isn't .. from what i previously have seen .. the max was around 13 if
> i recall correct, but i could put a check on that.
> And since i don't know *why* it fails .. it's hard to put a warn on it.
> 

Well, if you stick a printk of rx_last_skb_slots in rx_work_todo() in the case where there are not enough slots available then we may be able to see how many slots it's waiting for.

  Paul

> >   Paul
> 
> >> So that leads me to think it's something caused by this patch set.
> >> Patch1 could be a candidate .. perhaps that check was needed for some
> >> reason .. will see what not applying that one does
> >>
> >> --
> >> Sander
> >>
> >>
> >> >   Paul
> >>
> >> >> So it now seems i now have the situation which you described in the
> >> commit
> >> >> message from "ca2f09f2b2c6c25047cfc545d057c4edfcfe561c",
> >> >> "Without this patch I can trivially stall netback permanently by just
> doing a
> >> >> large guest to guest file copy between two Windows Server 2008R2
> VMs
> >> on a
> >> >> single host."
> >> >>
> >> >> --
> >> >> Sander
> >>
> >>
> 
> 
