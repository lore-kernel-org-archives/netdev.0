From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_mutex.patch
 [patch 4/6]
Date: Tue, 25 Nov 2008 10:42:13 +0000
Message-ID: <20081125104213.03b280c5@lxorguk.ukuu.org.uk>
References: <492ABECF.5050307@option.com>
	<20081125.003427.90695589.davem@davemloft.net>
	<20081125102043.0f318a8d@lxorguk.ukuu.org.uk>
	<20081125.022246.102969955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: D.Barow@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60685 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752302AbYKYKmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 05:42:06 -0500
In-Reply-To: <20081125.022246.102969955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I thought this was a network driver?

It's both, but the resource handling mess is on the tty side, and several
of the chunks (modem control etc) directly hit the tty parts and will
clash with other tty layer changes.
> 
> If so, this poor guy has respun these patches so many times
> my head is spinning, and making him wait for one more procedural
> thing is just a good way to deter yet another developer.

Well if you check the list I sent him a set of patches to review in
response to his posting. Those patches implement proper tty side
refcounting and have a chance of actually fixing the problems.

> I'm not leaving all of them out, most of them looked perfectly
> fine and didn't do any "tty" stuff.

That patch series is a complete mix:

1, 3 and 6 are network
2 is a broken tty layer patch
4 is a broken tty layer patch
5 is an ok tty layer patch

5 will go into the tty tree

2 and 4 clash with the tty tree already and don't deal with the tty side
locking at all sanely.

So I've no problem with the network parts (1,3,6) going into the netdev
tree but the other bits will make a mess if they do so.
