From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 11:12:15 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F149E8B4@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
	alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:7429 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1751338AbWECSMZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 14:12:25 -0400
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler
> (caitlinb@broadcom.com) wrote:
>>> I'd expect high end NIC ASICs to implement rx steering based upon
>>> some sort of hash (for load balancing), as well as explicit "1:1"
>>> steering between a sw channel and a hw channel. Both options for
>>> channel configuration are present in the driver interface.
>>> If netfilter assists can be done in hardware, I agree the driver
>>> interface will need to add support for these - otherwise, netfilter
>>> processing will stay above the driver.
>>> 
>>> 
>> 
>> Even if the hardware cannot fully implement netfilter rules there is
>> still value in having an interface that documents exactly how much
>> filtering a given piece of hardware can do.
>> There is no point in having the kernel repeat packet classifications
>> that have already been done by the NIC.
> 
> Please do not suppose that vj channel must rely on
> underlaying hardware.
> New interface MUST work better or at least not worse than
> existing skb queueing for majority of users, and I doubt
> users with netfilter capable hardware are there.
> It is only some hint to the SW, not rules, that hardware can provide.
> The best would be ipv4/ipv6 hashing, and I think it is enough.

I agree. I was just stating that *if* there is direct hardware 
support then the software should be enabled to skip 
redundant checks. What I'm suggesting is really the
equivalent of knowing whether the hardware generates
or checks CRCs and TCP checksums. Don't mandate
the feature, just have the option to avoid redundant work.

