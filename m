From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Mon, 21 Dec 2009 09:54:07 -0800
Message-ID: <20091221095407.5430a630@nehalam>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
	<20091218093240.64ca7d88@nehalam>
	<200912181901.28542.christian.samsel@rwth-aachen.de>
	<20091218.195907.189689401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christian.samsel@rwth-aachen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46202 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbZLURyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 12:54:35 -0500
In-Reply-To: <20091218.195907.189689401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 19:59:07 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Christian Samsel <christian.samsel@rwth-aachen.de>
> Date: Fri, 18 Dec 2009 19:01:28 +0100
> 
> > Am Freitag, 18. Dezember 2009 18:32:40 schrieb Stephen Hemminger:  
> >> On Fri, 18 Dec 2009 14:18:37 +0100
> >> 
> >> Christian Samsel <christian.samsel@rwth-aachen.de> wrote:  
> >> > This patch adds a new feature to netem: The newly introduced parameter
> >> > reorderdelay TIME is the time a reordered packet is delayed. It can be
> >> > used in a combination with delay TIME to enable netem to produce late
> >> > packets, which is not possible in the standard netem / iproute2. In the
> >> > standard version reordered packets are always sent immediately and
> >> > therefore are always early packets.  
> >> 
> >> I like the idea but is it binary compatible with older kernels/ older
> >>  iproute2 utilities?
> >>   
> > Thats a good point. I will test it. So far i think it should work.  
> 
> It won't work.
> 
> If you change the size of the tc_netem_qopt, older kernels will
> reject because the size is different from what the kernel expects.
> 
> So newer iproute2 will not work with older kernels.
> 
> You can't change these structures, add new netlink attributes
> to pass the new data instead.

The netem logic for parsing attributes is different from others for
historical reasons.  Looking at parse_attr():

If qopt is larger than expected, then the extra data is interpreted as
the following nested attribute.

If qopt is smaller than expected, then it returns -EINVAL.

Note: in early versions of netem development, the parsing was different,
and it was possible to grow the structure, but the attribute parsing got
changed and is now more restrictive.  BUT that is okay, since the correct
way to add options to netlink API's is to add new attributes, not extend
size of structures.
