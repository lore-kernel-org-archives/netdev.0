From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: Re: [RFC v2 1/2] net/hsr: Add support for IEC 62439-3
 High-availability Seamless Redundancy
Date: Wed, 4 Jul 2012 22:34:11 +0000
Message-ID: <4FF4C4E2.8010709@xdin.com>
References: <4FF38A5C.9000802@xdin.com>
 <20120703212011.4a2e343f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Javier Boticario <jboticario@gmail.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:63023 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755910Ab2GDWeN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 18:34:13 -0400
In-Reply-To: <20120703212011.4a2e343f@nehalam.linuxnetplumber.net>
Content-Language: en-US
Content-ID: <E4B6FE55BBEC11409BCD6A33122B39D1@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-07-04 06:20, Stephen Hemminger wrote:
> On Wed, 4 Jul 2012 00:12:13 +0000
> Arvid Brodin <Arvid.Brodin@xdin.com> wrote:
> 
>> diff --git a/Documentation/networking/hsr/hsr_genl.c b/Documentation/networking/hsr/hsr_genl.c
> 
> 1. I like documentation, I like examples, but examples in the Documentation
> directory get stale and end up not working.

I'd really like to supply this example code, because frankly, the documentation on Generic
Netlink with libnl isn't very good if you aren't already "in the know". It took some time
to figure this out.

Any better idea on where to place it? Would it help if I added a "Written <date>" in the
header comment so that people at least see when it is out of date?


> 2. I am not a fan of the non-standard unaligned access optimization.
> Stinks too much like the old BSD IFF_TRAILERS thing that still persists
> to this day.

Ok, I'll just remove it then, no problem.


> 3. The code seems to go to a lot of locking effort to get atomic state
>    update, if it used the bits in dev_state (ie netif_carrier etc) instead of
>    operstate and if_flags I think it would be simpler and safer.  I.e
> 
> +static int is_admin_up(struct net_device *dev)
> +{
> +	return (dev->flags & IFF_UP);
> +}
>     is redundant with netif_running()

Not sure what you mean by neither "a lot of locking effort" nor "atomic state update" here?

netif_running() checks __LINK_STATE_START. This has got to do with carrier state rather
than administrative state, right? So they're not the same? Actually I'm pretty confused by
the state tracking of network devices...

It doesn't seem to be normal practice to change operstate like I do, so I'm probably not
doing it right. Linkwatch sets IF_OPER_LOWERLAYERDOWN in default_operstate()
(net/core/link_watch.c) if !netif_carrier_ok(dev) and (dev->ifindex != dev->iflink). Can I
use this for my virtual hsr device driver somehow? I guess it should be
IF_OPER_LOWERLAYERDOWN if it's admin UP but both slaves are inoperable.

(The linkwatch reference to IF_OPER_LOWERLAYERDOWN is the only one that I can find.)


> 
> 4. Don't use mixed case as in:
>      +	HSR_Ver = 0;

I was a bit unsure about this. The HSR_Ver (and others like MacAddressA, HSR_TLV_Length
etc) are the names as written in the HSR IEC standard. Is it still desirable that I change
them to lower case?

> 
> 5. The header create code has to handle error cases where:
>      1. skb must be copied to add header
>      2. no space left for header in skb
> 
> 6. Don't comment out code and then submit it. I don't like reading and
>    reviewing leftover debug stuff.

Ok, sorry about that.


> 7. Any operations type structure should be declared 'const'. This is safer
>    from a security point of view and keeps dirty and immutable variables in separate
>    cache areas.
> 
> 8. If possible use standard netdev macros for printing info messages:
>      see netdev_info() etc.
> 
> 9. Be careful about variable names: "seqlock" implies you are using 
>     seq_lock() but you aren't doing that. It is just a spinlock.
> 
> 10. above() seems like it could be done by signed math in one operation
>     without conditional ?: operation.
>    See timer_before/timer_after for example.
> 
> 11. All global variables need to have one prefix.  You are using both hsr_
>      and framreg_. Can you just use hsr_?
> 

Thank you for your time on this. I'll take care of these issues when I get back from my
vacation, which is long overdue. Thanks!

-- 
Arvid Brodin | Consultant (Linux)
XDIN AB | Jan Stenbecks Torg 17 | SE-164 40 Kista | Sweden | xdin.com