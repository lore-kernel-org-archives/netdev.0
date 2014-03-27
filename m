From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v2 1/3] xen-netback: remove pointless clause from if
 statement
Date: Thu, 27 Mar 2014 17:26:55 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029D498@AMSPEX01CL01.citrite.net>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
 <1395924973-42904-2-git-send-email-paul.durrant@citrix.com>
 <289461862.20140327144546@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net>
 <68689563.20140327150256@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net>
 <874580615.20140327174607@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029D28D@AMSPEX01CL01.citrite.net>
 <636041055.20140327181524@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:1362 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870AbaC0R05 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:26:57 -0400
In-Reply-To: <636041055.20140327181524@eikelenboom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> Sent: 27 March 2014 17:15
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei Liu
> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause from if
> statement
> 
> 
> Thursday, March 27, 2014, 5:54:05 PM, you wrote:
> 
> >> -----Original Message-----
> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> Sent: 27 March 2014 16:46
> >> To: Paul Durrant
> >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei
> Liu
> >> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause
> from if
> >> statement
> >>
> >>
> >> Thursday, March 27, 2014, 3:09:32 PM, you wrote:
> >>
> >> >> -----Original Message-----
> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> >> Sent: 27 March 2014 14:03
> >> >> To: Paul Durrant
> >> >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell;
> Wei
> >> Liu
> >> >> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause
> >> from if
> >> >> statement
> >> >>
> >> >>
> >> >> Thursday, March 27, 2014, 2:54:46 PM, you wrote:
> >> >>
> >> >> >> -----Original Message-----
> >> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> >> >> Sent: 27 March 2014 13:46
> >> >> >> To: Paul Durrant
> >> >> >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian
> Campbell;
> >> Wei
> >> >> Liu
> >> >> >> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless
> clause
> >> >> from if
> >> >> >> statement
> >> >> >>
> >> >> >>
> >> >> >> Thursday, March 27, 2014, 1:56:11 PM, you wrote:
> >> >> >>
> >> >> >> > This patch removes a test in start_new_rx_buffer() that checks
> >> whether
> >> >> >> > a copy operation is less than MAX_BUFFER_OFFSET in length,
> since
> >> >> >> > MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only
> caller
> >> of
> >> >> >> > start_new_rx_buffer() already limits copy operations to
> PAGE_SIZE
> >> or
> >> >> less.
> >> >> >>
> >> >> >> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> >> >> >> > Cc: Ian Campbell <ian.campbell@citrix.com>
> >> >> >> > Cc: Wei Liu <wei.liu2@citrix.com>
> >> >> >> > Cc: Sander Eikelenboom <linux@eikelenboom.it>
> >> >> >> > ---
> >> >> >>
> >> >> >> > v2:
> >> >> >> >  - Add BUG_ON() as suggested by Ian Campbell
> >> >> >>
> >> >> >> >  drivers/net/xen-netback/netback.c |    4 ++--
> >> >> >> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >> >> >>
> >> >> >> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> >> >> >> netback/netback.c
> >> >> >> > index 438d0c0..72314c7 100644
> >> >> >> > --- a/drivers/net/xen-netback/netback.c
> >> >> >> > +++ b/drivers/net/xen-netback/netback.c
> >> >> >> > @@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset,
> >> >> >> unsigned long size, int head)
> >> >> >> >          * into multiple copies tend to give large frags their
> >> >> >> >          * own buffers as before.
> >> >> >> >          */
> >> >> >> > -       if ((offset + size > MAX_BUFFER_OFFSET) &&
> >> >> >> > -           (size <= MAX_BUFFER_OFFSET) && offset && !head)
> >> >> >> > +       BUG_ON(size > MAX_BUFFER_OFFSET);
> >> >> >> > +       if ((offset + size > MAX_BUFFER_OFFSET) && offset &&
> !head)
> >> >> >> >                 return true;
> >> >> >> >
> >> >> >> >         return false;
> >> >> >>
> >> >> >> Hi Paul,
> >> >> >>
> >> >> >> Unfortunately .. no good ..
> >> >> >>
> >> >> >> With these patches (v2) applied to 3.14-rc8 it all seems to work well,
> >> >> >> until i do my test case .. it still chokes and now effectively
> permanently
> >> >> stalls
> >> >> >> network traffic to that guest.
> >> >> >>
> >> >> >> No error messages or anything in either xl dmesg or dmesg on the
> host
> >> ..
> >> >> and
> >> >> >> nothing in dmesg in the guest either.
> >> >> >>
> >> >> >> But in the guest the TX bytes ifconfig reports for eth0 still increase
> but
> >> RX
> >> >> >> bytes does nothing, so it seems only the RX path is effected)
> >> >> >>
> >> >>
> >> >> > But you're not getting ring overflow, right? So that suggests this
> series is
> >> >> working and you're now hitting another problem? I don't see how
> these
> >> >> patches could directly cause the new behaviour you're seeing.
> >> >>
> >> >> Don't know  .. how ever .. i previously tested:
> >> >>         - unconditionally doing "max_slots_needed + 1"  in
> "net_rx_action()",
> >> >> and that circumvented the problem reliably without causing anything
> else
> >> >>         - reverting the calculation of "max_slots_needed + 1"  in
> >> >> "net_rx_action()" to what it was before :
> >> >>                 int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> >> >>                 if (vif->can_sg || vif->gso_mask || vif->gso_prefix_mask)
> >> >>                         max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> >> >>
> >>
> >> > So, it may be that the worse-case estimate is now too bad. In the case
> >> where it's failing for you it would be nice to know what the estimate was
> 
> 
> > Ok, so we cannot be too pessimistic. In that case I don't see there's a lot of
> > choice but to stick with the existing DIV_ROUND_UP (i.e. don't assume
> > start_new_rx_buffer() returns true every time) and just add the extra 1.
> 
> Hrmm i don't like a "magic" 1 bonus slot, there must be some theoretical
> backing.

I don't like it either, but theory suggested each frag should take no more space than the original DIV_ROUND_UP and that proved to be wrong, but I cannot figure out why.

> And since the original problem always seemed to occur on a packet with a
> single large frag, i'm wondering
> if this 1 would actually be correct in other cases.

That's why I went for an extra 1 per frag... a pessimal slot packing i.e. 2 byte frag may span 2 slots, PAGE_SIZE + 2 bytes may span 3, etc. etc.

> 
> Well this is what i said earlier on .. it's hard to estimate upfront if
> "start_new_rx_buffer()" will return true,
> and how many times that is possible per frag .. and if that is possible for only
> 1 frag or for all frags.
> 
> The problem is now replaced from packets with 1 large frag (for which it
> didn't account properly leading to a too small estimate) .. to packets
> with a large number of (smaller) frags .. leading to a too large over
> estimation.
> 
> So would there be a theoretical maximum how often that path could hit
> based on a combination of sizes (total size of all frags, nr_frags, size per frag)
> ?
> - if you hit "start_new_rx_buffer()" == true  in the first frag .. could you hit it
> in a next frag ?
> - could it be limited due to something like the packet_size / nr_frags /
> page_size ?
> 
> And what was wrong with the previous calculation ?
>                  int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
>                  if (vif->can_sg || vif->gso_mask || vif->gso_prefix_mask)
>                          max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> 

This is not safe if frag size can be > PAGE_SIZE.

> That perhaps also misses some theoretical backing, what if it would have
> (MAX_SKB_FRAGS - 1) nr_frags, but larger ones that have to be split to
> fit in a slot. Or is the total size of frags a skb can carry limited to
> MAX_SKB_FRAGS / PAGE_SIZE ? .. than you would expect that
> MAX_SKB_FRAGS is a upper limit.
> (and you could do the new check maxed by MAX_SKB_FRAGS so it doesn't
> get to a too large non reachable estimate).
> 
> But as a side question .. the whole "get_next_rx_buffer()" path is needed
> for when a frag could not fit in a slot
> as a whole ?
> 

Perhaps it would be best to take the hit on copy_ops and just tightly pack, so we only start a new slot when the current one is completely full; then actual slots would simply be DIV_ROUND_UP(skb->len, PAGE_SIZE) (+ 1 for the extra if it's a GSO).

  Paul
