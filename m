From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 08:56:23 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F149E880@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:47110 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030222AbWECP4k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 11:56:40 -0400
Content-class: urn:content-classes:message
To: "Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of David S. Miller
>> Sent: Tuesday, May 02, 2006 11:48 PM
>> To: shemminger@osdl.org
>> Cc: alex@neterion.com; netdev@vger.kernel.org
>> Subject: Re: VJ Channel API - driver level (PATCH)
>> 
>> 
>> I don't think we should be defining driver APIs when we haven't even
>> figured out how the core of it would even work yet.
>> 
>> A key part of this is the netfilter bits, that will require
>> non-trivial flow identification, a hash will simply not be enough,
>> and it will not be allowed to not support the netfilter bits properly
>> since everyone will have netfilter enabled in one way or another.
> 
> Hi Dave,
> 
> Do you have suggestions on potential hardware
> assists/offloads for netfilter?
> 
> I suppose some of it can be worthwhile, although in general
> may be too complex to implement - especially above 1 Gig.
> 
> I'd expect high end NIC ASICs to implement rx steering based
> upon some sort of hash (for load balancing), as well as
> explicit "1:1" steering between a sw channel and a hw
> channel. Both options for channel configuration are present
> in the driver interface.
> If netfilter assists can be done in hardware, I agree the
> driver interface will need to add support for these -
> otherwise, netfilter processing will stay above the driver.
> 
> 

Even if the hardware cannot fully implement netfilter rules
there is still value in having an interface that documents 
exactly how much filtering a given piece of hardware can do.
There is no point in having the kernel repeat packet classifications
that have already been done by the NIC.

