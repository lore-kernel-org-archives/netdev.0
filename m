From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 19:41:25 +0300
Message-ID: <20070220164124.GA24930@2ka.mipt.ru>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36374 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030253AbXBTQle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:41:34 -0500
Content-Disposition: inline
In-Reply-To: <20070220162714.GA3245@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 05:27:14PM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> I've done so, with some interesting results. Source on
> http://ds9a.nl/tmp/recvtimings.c - be careful to adjust the '3000' divider
> to your CPU frequency if you care about absolute numbers!
> 
> These are two groups, each consisting of 10 consecutive nonblocking UDP
> recvfroms, with 10 packets preloaded. Reported is the number of microseconds
> per recvfrom call which yielded a packet:
> 
> $ ./recvtimings
> 4.142333

It can be recvfrom only problem - syscall overhead on my p4 (core duo,
debian testing) is bout 300 usec - to test I ran 
read('dev/zero', &data, 0)
in a loop.

Could you try to hack recvfrom() for your socket to always copy some
empty buffer and check the results without waiting for packet?

If you are not hurry I can test it myself tomorrow.

-- 
	Evgeniy Polyakov
