From: "David S. Miller" <davem@davemloft.net>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Mon, 15 May 2006 15:49:39 -0700 (PDT)
Message-ID: <20060515.154939.28171388.davem@davemloft.net>
References: <OFE8460E54.0C8D85D8-ON8525716F.0074F22F-8825716F.0076D537@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9617
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750708AbWEOWtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 18:49:43 -0400
To: mark1smi@us.ibm.com
In-Reply-To: <OFE8460E54.0C8D85D8-ON8525716F.0074F22F-8825716F.0076D537@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark A Smith <mark1smi@us.ibm.com>
Date: Mon, 15 May 2006 14:39:06 -0700

> I discovered that in some cases, send(), sendmsg(), and sendto() are not
> thread-safe. Although the man page for these functions does not specify
> whether these functions are supposed to be thread-safe, my reading of the
> POSIX/SUSv3 specification tells me that they should be. I traced the
> problem to tcp_sendmsg(). I was very curious about this issue, so I wrote
> up a small page to describe in more detail my findings. You can find it at:
> http://www.almaden.ibm.com/cs/people/marksmith/sendmsg.html .

I don't understand why the desire is so high to ensure that
individual threads get "atomic" writes, you can't even ensure
that in the general case.

Only sloppy programs that don't do their own internal locking hit into
issues in this area.

>From your findings, the vast majority of systems you investigated do
not provide "atomic" thread safe write semantics over TCP sockets.
And frankly, BSD defines BSD socket semantics here not some wording in
the POSIX standards.

Finally, this discussion belongs on the networking development mailing
list, netdev@vger.kernel.org, not linux-kernel.
