From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 17:05:58 -0400
Message-ID: <1237323962-18635-1-git-send-email-vladislav.yasevich@hp.com>
References: <20090317.123146.210941276.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6417 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbZCQVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:06:08 -0400
In-Reply-To: <20090317.123146.210941276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Regardless of how we may feel about this thread, it did make me run
the BSD bindtest utility and look at the results.  What I found was
rather surprising.

There were multiple tests that one would exptect to succeed, but they
were failing.

Things that I consider broken:
  1) We can bind to a v4-mapped IPv6 address on a v6-only socket.
  2) We conflict IPv4 wildcrads with explicit IPv6 addresses and vice-versa
  3) We inconsitently treat V4 address and v4-mapped addresses.  As an example,
     try binging to 0.1.2.3. (This also kind of goes to binding
     ::ffff:0.0.0.0).

The following 4 RFC patches attempt to fix this.  I've run bindtest tool and
am currently analizing the results.  They look a heck of a lot better.

Thanks
-vlad

