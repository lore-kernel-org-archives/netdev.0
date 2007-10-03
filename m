From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Wed, 03 Oct 2007 09:18:18 -0400
Message-ID: <1191417498.4357.23.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <47028351.7090509@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:1377 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbXJCNSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 09:18:23 -0400
Received: by nz-out-0506.google.com with SMTP id s18so3252602nze
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 06:18:22 -0700 (PDT)
In-Reply-To: <47028351.7090509@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-10 at 10:43 -0700, Kok, Auke wrote:

> the description of this patch is rather misleading, and the title certainly too.

That was fast - you said weeks, not days;->

> Can you resend this with a bit more elaborate explanation as to why the cb code is
> relevant to use here? Not only do I need to understand this, but others might want
> to as well later on ;)

I am probably repeating something youve seen/know already.
The cleanup is to break up the code so it is functionally more readable
from a perspective of the 4 distinct parts in ->hard_start_xmit():

a) packet formatting (example: vlan, mss, descriptor counting, etc.)
b) chip-specific formatting
c) enqueueing the packet on a DMA ring
d) IO operations to complete packet transmit, tell DMA engine to chew
on, tx completion interrupts, set last tx time, etc.

Each of those steps sitting in different functions accumulates state
that is used in the next steps. cb stores this state because it a
scratchpad the driver owns. You could create some other structure and
pass it around the iteration, but why waste more bytes.

I could stop there with the explanation, but let me go on .. ;->

>From a secondary angle, remember i am pulling these patches out of my
batching work. Thats how we started this discussion ;-> I would like,
once converted the driver to remove LLTX, to do #a without holding the
tx lock. This stands on its own even without batching. Then of course,
once all this is in such good shape it makes it easier to add the
batching code because i could reuse the now functionalized steps.
I hope that provides reasonable and good explanation ;->

cheers,
jamal

