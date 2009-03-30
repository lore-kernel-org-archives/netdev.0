From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: TX time stamping
Date: Mon, 30 Mar 2009 20:09:40 +0200
Message-ID: <49D10AE4.8070907@hartkopp.net>
References: <1236105081.4653.68.camel@pohly-MOBL>	 <20090319.140509.152824531.davem@davemloft.net>	 <20090320021050.GA7021@gondor.apana.org.au>	 <1237964924.26966.310.camel@pohly-MOBL>	 <20090326144835.GA19592@gondor.apana.org.au> <1238081410.19066.125.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:43547 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbZC3SJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:09:50 -0400
In-Reply-To: <1238081410.19066.125.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly wrote:
> On Thu, 2009-03-26 at 14:48 +0000, Herbert Xu wrote:
>> On Wed, Mar 25, 2009 at 08:08:44AM +0100, Patrick Ohly wrote:
>>> I suggest to make it so that the sender gets the packet back once per
>>> interface, with different time stamps and information about the
>>> interface.
>> That could be awkward.  What if the second or subsequent instance
>> of the packet is held up indefinitely?
> 
> The sender must be prepared for packet loss anyway (for example, during
> stress tests I have seen that packets were dropped between socket layer
> and device driver).
> 
> Getting a TX time stamp only for some, but not all expected interfaces,
> or getting some results much later isn't that different.
> 
> After a certain timeout the sender must assume that the packet was lost
> and resend. An unexpected response for a packet that was supposed to be
> lost must be ignored.
> 

Hello Patrick,

i wonder if using the IP stack for PTP with the possibility to send TX-stamped
 PDUs on various interfaces is the best solution.

I'm not aware of all the routing, packet scheduling, etc. stuff that much -
but does it probably make sense to use AF_PACKET for PTP, where you can
specify the interface and build a PTP IP PDU directly? I assume this does not
make that big difference to the ptpd in userspace.

Any ideas? Or am i completely wrong here?

Regards,
Oliver
