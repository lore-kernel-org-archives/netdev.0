From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 22 Oct 2008 21:10:27 +0200
Message-ID: <48FF7AA3.50408@gmail.com>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu> <48FF614C.7020507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:26354 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYJVTJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 15:09:13 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1036362eyi.37
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 12:09:11 -0700 (PDT)
In-Reply-To: <48FF614C.7020507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 10/22/2008 07:22 PM:

> Ferenc Wagner wrote, On 10/22/2008 05:00 PM:
> 
>> Ferenc Wagner <wferi@niif.hu> writes:
>>
>>> I expected an IP-less bridge interface to pick up no IP packets, but
>>> apparently this isn't the case: broadcast packets with destination
>>> address 255.255.255.255 are reported as martians by the 2.6.18
>>> kernel, which I find counterintuitive (I know 2.6.18 is rather old,
>>> but that's the one supported by Xen).
>>>
>>>   1. Is this the expected behaviour?
> 
> 
> I think so, and this thread pertains to something similar:
> http://marc.info/?l=linux-netdev&m=122456602708727&w=2

Sorry! I didn't check this before writing. This:

1941 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
1942                                u8 tos, struct net_device *dev)
1943 {
...
1963         /* IP on this device is disabled. */
1964
1965         if (!in_dev)
1966                 goto out;
1967
1968         /* Check for the most weird martians, which can be not detected
1969            by fib_lookup.
1970          */

means something else, so with IP disabled you shouldn't have any martians!
(And this is old code.)

Jarek P.
