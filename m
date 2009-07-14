From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Tue, 14 Jul 2009 16:28:01 -0700
Message-ID: <65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	 <20090713.104950.121936768.davem@davemloft.net>
	 <65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
	 <20090714.123313.186658126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:57238 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194AbZGNX2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 19:28:04 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n6ENS4Q7008583
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 16:28:04 -0700
Received: from qw-out-1920.google.com (qwk4.prod.google.com [10.241.195.132])
	by zps36.corp.google.com with ESMTP id n6ENS1Am015403
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 16:28:01 -0700
Received: by qw-out-1920.google.com with SMTP id 4so1072350qwk.16
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 16:28:01 -0700 (PDT)
In-Reply-To: <20090714.123313.186658126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> > Right.  In fact, just using the hash as the key is what you want when
> > device provides the hash (i.e. Toeplitz).  The caveat is that we
> > should to prevent OOO packets when threads migrate, I think I have a
> > reasonable solution for that following your earlier suggestion.
>
> But as you found, compared to jhash, Toeplitz is expensive to compute
> and you would need to do this if implemented by monitoring transmits.

Well I'd rather not have to compute any hash on transmit.  Toeplitz
could be populated in another field of skb from a saved value in the
socket struct.

>
> And furthermore, from the device perspective:
>
> 1) some (such as NIU) provide different hash values, not Toeplitz
>
> 2) it is expensive to extract this value (must enable different,
>   larger, RX descriptor modes, thus more DMA traffic, etc.)
>
> I really don't think Toeplitz is a net win, to be honest.

Using the Toeplitz hash in steering lookup has given us about 10% more
maximum pps (2 different NICs), and we haven't really noticed negative
effects because of the extra descriptor overhead-- so I'm not going to
give up on it too easily!  A device provided hash could probably be
used as an opaque value-- used as hash key into steering table on RX,
saved in socket structure in RX, and then sent with skb on transmit
during which it is used to update the steering table.  At the socket
layer, we would just need to collect and cache values in socket
structures.

>
> > I hope to have a new patch soon for steering packets to application
> > CPU and using device hash, thanks for bugging me on it!
>
> I had no choice, as I'm giving a presentation on this stuff tomorrow
> night here in NYC :-)

Cool, do you happen to have slides.... :-)
