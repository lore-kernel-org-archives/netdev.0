From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Mon, 06 Aug 2007 15:21:48 +0200
Message-ID: <46B7206C.30101@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200708060949.58758.joakim.koskela@hiit.fi> <46B70F2C.6090807@trash.net> <200708061607.28259.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932886AbXHFNWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 09:22:09 -0400
In-Reply-To: <200708061607.28259.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> On Monday 06 August 2007 15:08:12 Patrick McHardy wrote:
> 
>>>It's been a while, but as a fyi in case there are comments / suggestions
>>>before submitting the whole patch again - it seems that this had some
>>>problems after all. Works ok for normal cases, but fails when using ip
>>>options for the inner packet as they don't get processed after being
>>>extracted from the pseudoheader. Calling something like
>>>ip_options_compile from beet_mode's input when handling ipv4 would do the
>>>trick, but seems a bit ugly & perhaps unsafe, I'd rather just put the
>>>whole packet through the loop again.
>>
>>Won't the options get parsed by ip_rcv() on the second reception?
> 
> 
> Yes. The thing was that it seemed like we could get by with only a 
> transport-mode- amount of processing of same-family beet packets. But unless 
> we do some special processing during beet reception (which doesn't seem that 
> elegant), it won't work. So I'm changing it back to tunnel-like processing.


I think you could parse the options directly after decapsulation
in xfrm4_mode_beet.c, that doesn't seem very ugly to me.
