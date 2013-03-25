From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Mon, 25 Mar 2013 17:08:55 +0100
Message-ID: <20130325170855.0194ce13@griffin>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
	<20130321.172017.1499060411785395307.davem@davemloft.net>
	<20130323175915.GA3036@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758417Ab3CYQJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 12:09:02 -0400
In-Reply-To: <20130323175915.GA3036@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Mar 2013 18:59:15 +0100, Richard Cochran wrote:
> Jiri, do you want to work on making the number of clocks essentially
> unlimited? If not, I can take a look at this, but not right away.

I'm currently thinking of using just /dev/ptp for all PHCs in the
system and specifying the desired network device (ifindex, likely)
by an ioctl as the very first operation. What do you think? If this
is viable, I can try to implement it.

As for netlink, I don't see how to do that without reimplementing the
whole kernel<->user space timer API. The API expects clockid_t which
is either a const (a new constant wouldn't help, we can have multiple
PHCs in the system), or a dynamic value. There is no space for more
dynamic values as far as I can see, all combinations of the three lower
bits are already defined. It seems we're left with file descriptors.

 Jiri

-- 
Jiri Benc
