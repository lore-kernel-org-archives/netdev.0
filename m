From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may
 need to happen earlier
Date: Fri, 12 Jul 2013 09:56:07 +0100
Message-ID: <51DFE0C702000078000E462A@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
 <20130712083248.GF23269@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <davem@davemloft.net>,
	"Dion Kant" <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:38156 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757637Ab3GLI4K convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 12 Jul 2013 04:56:10 -0400
In-Reply-To: <20130712083248.GF23269@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 12.07.13 at 10:32, Wei Liu <wei.liu2@citrix.com> wrote:
> On Mon, Jul 08, 2013 at 03:20:26PM +0100, Jan Beulich wrote:
>> >>> On 08.07.13 at 11:59, "Jan Beulich" <JBeulich@suse.com> wrote:
>> >>>> On 05.07.13 at 16:53, Wei Liu <wei.liu2@citrix.com> wrote:
>> >> 	skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
>> >> 	skb->len += skb->data_len;
>> >>     }
>> >> 
>> >>     handle_incoming_packet();
>> >> 
>> >> You seem to be altering the behavior of the original code, because in
>> >> your patch the skb->len is incremented before use, while in the original
>> >> code (which calls skb_headlen in handle_incoming_packet) the skb->len is
>> >> correctly set.
>> > 
>> > Right. So I basically need to keep skb->len up-to-date along with
>> > ->data_len. Just handed a patch to Dion with that done; I'll defer
>> > sending a v2 for the upstream code until I know the change works
>> > for our kernel.
>> 
>> Okay, so with that done (see below) Dion is now seeing the
>> WARN_ON_ONCE(delta < len) in skb_try_coalesce() triggering. Of
>> course, with it having crashed before, it's hard to tell whether the
>> triggering now is an effect of the patch, or just got unmasked by it.
>> 
> 
> I just ported your below patch to upstream kernel and I didn't see the
> WARN_ON_ONCE. I only did iperf and netperf tests.
> 
> If the work load to trigger this bug is simple enough I can give it a
> shot...

I'm meanwhile relatively convinced that the warning isn't an effect
of the patch (final verification pending); I intend to submit v2 as
soon as 3.11-rc1 is out.

Jan
