From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Fri, 30 Oct 2015 14:23:54 -0700
Message-ID: <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
References: <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151028211347.GC22011@ZenIV.linux.org.uk>
	<1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151028223330.GD22011@ZenIV.linux.org.uk>
	<1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029001532.GE22011@ZenIV.linux.org.uk>
	<1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029041611.GF22011@ZenIV.linux.org.uk>
	<1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	<20151030210215.GI22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37901 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030565AbbJ3VXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 17:23:55 -0400
In-Reply-To: <20151030210215.GI22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 2:02 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Your variant has 1:64 ratio; obviously better than now, but we can actually
> do 1:bits-per-cacheline quite easily.

Ok, but in that case you end up needing a counter for each cacheline
too (to count how many bits, in order to know when to say "cacheline
is entirely full").

Because otherwise you'll end up having to check the whole cacheline
(rather than check just one word, or check the "bit counter") when you
set a bit.

So I suspect a "bitmap of full words" ends up being much simpler.  But
hey, if you can make your more complex thing work, go right ahead.

               Linus
