From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast	messages
Date: Wed, 15 Apr 2009 14:42:06 -0700
Message-ID: <OFC72984F0.3784D936-ON88257599.007609F8-88257599.00773519@us.ibm.com>
References: <49E5F1FF.1000801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:41890 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbZDOVmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 17:42:10 -0400
In-Reply-To: <49E5F1FF.1000801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad, Neil,
        [Sorry if I'm behind -- just saw this thread...]

> Here is a rather pertinent text that points out that we "might" have a 
bug.
> RFC 4607:
> 
> 4.2.  Requirements on the Host IP Module
> 
>    An incoming datagram destined to an SSM address MUST be delivered by
>    the IP module to all sockets that have indicated (via Subscribe) a
>    desire to receive data that matches the datagram's source address,
>    destination address, and arriving interface.  It MUST NOT be
>    delivered to other sockets.
> 
> 
> Additionally, RFC 3678 describes IP_ADD_MEMBERSHIP as an 'any-source 
group'
> and is allowed by the SSM spec.  This is also how it is implemented in 
the kernel.
> However, we do not appear to perform the filtering required by the above 
quoted
> section 4.2.  In particular, if we fail to match the 'datagram's 
destination address',
> we deliver the packet, which I believe is in violation of the "MUST NOT" 
above.

        "SSM" stands for "Source-Specific Multicast". "Any source" is 
explicitly
*not* source-specific. Nothing in RFC 4607 is intended to change legacy 
behavior
where there is no source filtering. If you do SSM on Linux, you will have 
the
group-join check.
        The legacy behavior you don't like was not a bug in BSD. It was 
intentional
and authored by Steve Deering, who is also the author of the original 
multicast
RFC. The intent was that multicast address socket behavior would be just 
like
unicast address behavior, with the exception that multicast addresses are
interface-specific. If you add a new unicast address to the machine, and
the binding on the socket doesn't restrict it, you will receive packets
from any of the addresses on the machine. That's what INADDR_ANY means. 
Your
multicast application may also receive unicast traffic on that port too.
        It does seem to cause a lot of confusion for people, though I'm 
not
sure why. *Any* multicast application can receive traffic not intended for
it because there is no exclusion on multicast senders. So, applications 
must
handle packets not for it, period. Unless you have an IANA-allocated 
multicast
address and port, someone else may use it for something else on the same
network, while still following the rules. And if you do have assigned 
addresses
and ports, someone may send you garbage, anyway.
        I'll read the rest of the thread and see if there's any more to 
respond
to... :-)

 +-DLS


