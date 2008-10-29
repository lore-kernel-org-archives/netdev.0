From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 29 Oct 2008 17:56:17 +0100
Message-ID: <87y707mjbi.fsf@tac.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
	<48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:58346 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167AbYJ2Q4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 12:56:21 -0400
In-Reply-To: <48FF7AA3.50408@gmail.com> (Jarek Poplawski's message of "Wed, 22
	Oct 2008 21:10:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> Jarek Poplawski wrote, On 10/22/2008 07:22 PM:
>
>> Ferenc Wagner wrote, On 10/22/2008 05:00 PM:
>> 
>>> Ferenc Wagner <wferi@niif.hu> writes:
>>>
>>>> I expected an IP-less bridge interface to pick up no IP packets, but
>>>> apparently this isn't the case: broadcast packets with destination
>>>> address 255.255.255.255 are reported as martians by the 2.6.18
>>>> kernel, which I find counterintuitive (I know 2.6.18 is rather old,
>>>> but that's the one supported by Xen).
>>>>
>>>>   1. Is this the expected behaviour?
>> 
>> I think so, and this thread pertains to something similar:
>> http://marc.info/?l=linux-netdev&m=122456602708727&w=2
>
> Sorry! I didn't check this before writing. This:
>
> 1941 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> 1942                                u8 tos, struct net_device *dev)
> 1943 {
> ...
> 1963         /* IP on this device is disabled. */
> 1964
> 1965         if (!in_dev)
> 1966                 goto out;
> 1967
> 1968         /* Check for the most weird martians, which can be not detected
> 1969            by fib_lookup.
> 1970          */
>
> means something else, so with IP disabled you shouldn't have any martians!
> (And this is old code.)

Hi Jarek,

Thanks for your comments.  To tell the truth, I'm quite confused about
the host-based addressing model.  If the addresses belong to the host,
then why do we add them to interfaces?

In my case, the bridge itself (?) has no IP addresses assigned, but
an other interface (which isn't a bridge port) does have.  In other
words, the only network interface of the host is a bond interface
aggregating the two physical Ethernet interfaces; the two IP addresses
of the host are assigned to this bond0.

bond0 is also the raw interface of several .1q VLAN interfaces, which
are ports of bridges (there is one bridge for each VLAN but the native
above).  The other ports of the bridges are the virtual interfaces of
the Xen guests running on this host.  If I run ping -b 255.255.255.255
on one such guest, that gives a "martian source 255.255.255.255"
warning on the given bridge.  Even though 255.255.255.255 is the
destination address of that ping packet...

And this happens on 2.6.26.6, too.  Can't it come from
ip_mkroute_input instead of ip_route_input_slow?
-- 
Regards,
Feri.
