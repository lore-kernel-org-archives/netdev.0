From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Tue, 12 Nov 2013 06:16:25 -0800
Message-ID: <1384265785.28458.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
	 <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.37647.979237.40802@gargle.gargle.HOWL>
	 <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com>
	 <1384183799.16391.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com>
	 <1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73FD@saturn3.aculab.com>
	 <20131112074243.GA10318@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Sujith Manoharan <sujith@msujith.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:47120 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3KLOQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 09:16:28 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so6561144pab.26
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 06:16:27 -0800 (PST)
In-Reply-To: <20131112074243.GA10318@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 08:42 +0100, Willy Tarreau wrote:

> Well, it's not *that* large, 532 descriptors is 800 kB or 6.4 ms with
> 1500-bytes packets, and 273 microseconds for 64-byte packets. In fact
> it's not a slow interface, it's the systems it runs on which are
> generally not that fast. For example it is possible to saturate two
> gig ports at once on a single-core Armada370. But you need buffers
> large enough to compensate for the context switch time if you use
> multiple threads to send.

With GSO, each 1500-bytes packet might need 2 descriptors anyway (one
for the headers, one for the payload), so 532 descriptors only hold 400
kB or 3.2 ms ;)

If the NIC was supporting TSO, this would be another story, as a 64KB
packet could use only 3 descriptors.
