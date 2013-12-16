From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 2/3] packet: fill the gap of TPACKET_ALIGNMENT with
 zeros
Date: Mon, 16 Dec 2013 11:22:35 +0100
Message-ID: <52AED46B.3090601@redhat.com>
References: <87ob4h6wq1.wl%atzm@stratosphere.co.jp> <52AED170.9020604@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7491@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Atzm Watanabe <atzm@stratosphere.co.jp>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558Ab3LPKWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:22:45 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7491@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 11:16 AM, David Laight wrote:
>>> +		memset(h.h2->tp_padding, 0,
>>> +		       hdrlen - offsetof(struct tpacket2_hdr, tp_padding));
>
> What is wrong with 'sizeof h.h2->tp_padding' ?
> The compiler will probably inline the memset into a couple of word
> sized writes of zero - probably not measurable.
> Not zeroing them might be leaking kernel memory contents (depends
> where the memory came from - might just be stale packet data).

The ring buffer memory we're operating on comes from mmap(2) btw.

> 	David
>
>
>
