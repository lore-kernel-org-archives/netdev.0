From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 15:37:09 -0500
Message-ID: <20151116203709.GA27178@oracle.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20872 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKPUhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:37:24 -0500
Content-Disposition: inline
In-Reply-To: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/16/15 21:14), Jason A. Donenfeld wrote:
> 
> But what about in devices for which self-routing might actually be
> useful? For example, let's say that if an incoming skb is headed for
> dst X, it gets encapsulated and sent to dst A, and for dst Y it gets
> encapsulated and sent to dst B, and for dst Z it gets encapsulated and
> sent to dst C. I can imagine situations in which setting A==Y and B==Z
> might be useful to do multiple levels of encapsulation on one device,
> so that skbs headed for dst X get sent to dst C, but with intermediate
> transformations of dst A and dst B.

I believe that what you are talking about is basically nested encapsulation-
see https://tools.ietf.org/html/rfc2473. 

The tunnelling endpoint could track the number of encapsulations and keep
a limit on that? (conceptually this may be the same thing as your ttl
proposal, except that "ttl" has other meanings in other contexts, so
a bit non-intuitive) 

--Sowmini

(fwiw, RFC 2473 proposes an ipv6 option to track nested encapsulation,
and that never took off, because, among other reasons, its hard to
offload such options to hardware. Anyway, you are not trying to carry
this around in the packet).
