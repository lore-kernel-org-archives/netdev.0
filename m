From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Treason uncloaked / Broken peer again
Date: Sat, 21 Feb 2009 23:34:54 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902212317410.20526@wrl-59.cs.helsinki.fi>
References: <20090221195829.GA14779@bx9.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Greg Lindahl <greg@blekko.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:32863 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbZBUVe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 16:34:56 -0500
In-Reply-To: <20090221195829.GA14779@bx9.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Feb 2009, Greg Lindahl wrote:

> A recent set of fiddling to our web crawler has resulted in crawled
> Linux hosts frequently getting "Treason uncloaked" messages in their
> dmesg. This has resulted in a modest amount of hate mail, surprisingly
> little given that we crawl millions of hosts per day.
> 
> We're running the RHEL 5.2's kernel, and I have a remote webserver of
> my own running RHEL 5.2 that's getting the messages. If you look in
> your own webserver dmesg and see treason emanating from
> 38.108.180.XXX/24, that's me.
>
> Unfortunately, I haven't made the thing deterministic. My suspicion is
> that there's another bug similar to:
> 
> http://github.com/github/linux-2.6/commit/2ad41065d9fe518759b695fc2640cf9c07261dd2
> 
> Any advice on how to narrow down the bug? I was hoping I could get a
> tcpdump of a treasonous conversation and hand it over to you guys.

A case I remember top of the hat is related to shrinking of 
advertized window due to granularity steps because of window
scaling. Fixed 2.6.22-26 timeframe iirc.

Besides actually shrinking the window, it has is often proved to be so 
that TCP sent past the advertized window (which is a bug in itself) and 
then if the peer (in here, us) shrinks its window to zero at that point, 
the message gets triggered at the remote end (and will blame the wrong end 
:-)). So to avoid this your application must avoid causing zero window to 
prevent a fulfilment of the second requirement since you don't know if the 
remote end has that bug or not.


-- 
 i.
