From: "Daniel Pieczko (dpieczko)" <dpieczko@solarflare.com>
Subject: Re: [PATCH net-next] sfc: allocate rx pages on the same node as the
 interrupt
Date: Thu, 12 May 2016 11:35:39 +0100
Message-ID: <1e4520d2-d097-665c-c8b8-b6aef3d2ed9b@solarflare.com>
References: <5731EE51.2090908@solarflare.com>
 <1462892106.23934.77.camel@edumazet-glaptop3.roam.corp.google.com>
 <1462892223.23934.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:10383 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbcELKxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 06:53:11 -0400
In-Reply-To: <1462892223.23934.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/16 15:57, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 07:55 -0700, Eric Dumazet wrote:
>> If you care only of the initial pages allocated with GFP_KERNEL at
>> device start, really that is a small detail as they should be consumed
>> and replaced quite fast.

This patch was addressing just that situation.

>> If you worry that "wrong" pages would be reused over and over,
>> you could make sure that efx_reuse_page() wont reuse a page on the wrong
>> node.
>>
>> page_to_nid(page) != numa_mem_id()

Yes, that would solve the general problem and your patch looks correct
for the code as it is right now.

However, we have some pending changes to our rx recycle ring that
haven't been submitted upstream yet which will alter the way that pages
are reused, so the solution may no longer be so simple.  I think we
avoided making the simple change of checking page_to_nid() right now
because of these future changes to rx page recycling.

So I think that the original patch in this submission is valuable in
addressing the initial startup case - that won't be changed by the other
rx page recycling changes.

I have no preference on whether we take Eric's follow-up patch to check
page_to_nid() right now or wait until the other rx changes are submitted
and then fix it up as required.


Daniel
