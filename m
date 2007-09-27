From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e100 problems in .23rc8 ?
Date: Thu, 27 Sep 2007 14:58:27 +0800
Message-ID: <E1IanKN-0003ju-00@gondolin.me.apana.org.au>
References: <46FAA083.9020604@intel.com>
Cc: davej@redhat.com, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com (Kok, Auke)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2855 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752134AbXI0G6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 02:58:38 -0400
In-Reply-To: <46FAA083.9020604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> Dave Jones wrote:
>> Last night, I hit this bug during boot up..
>> http://www.codemonkey.org.uk/junk/e100-2.jpg
>> 
>> This morning, I got a mail from a Fedora user of the same
>> .23-rc8 based kernel that has seen a different trace
>> also implicating e100..
>> 
>> http://www.codemonkey.org.uk/junk/e100.jpg
>> 
>> It may be that the two problems are unrelated, and it's
>> just coincidence that both reports happen to be on an e100,
>> but the timing is odd.  Have there been other reports
>> of similar problems recently ?
> 
> there hasn't been a change to e100 in two months now - perhaps something slipped
> into the stack that broke it? If this reproduces, could you bisect?

Well this looks exactly like the e1000 race that we fixed around
the time of the last kernel release.  That fix never made it into
e100 so it's no surprise that we get a similar crash here.

The problem is that if a spurious interrupt comes in between
request_irq and netif_poll_enable then you'll get a crash at
the next netif_rx_complete.

It'd be good if this were reproducible as it would allow us
to identify the source of the spurious interrupt, which may
well be caused by an unrelated bug somewhere else.

In any case, e100 should be prepared to deal with spurious
interrupts as e1000 has been fixed to do.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
