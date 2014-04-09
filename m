From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Wed, 9 Apr 2014 22:35:15 +0200
Message-ID: <20140409203515.GF27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Francois WELLENREITER <f.wellenreiter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33413 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933885AbaDIUfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 16:35:17 -0400
Content-Disposition: inline
In-Reply-To: <5345A2B3.7040602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Apr 09, 2014 at 09:42:43PM +0200, Francois WELLENREITER wrote:
> I've been recently running performance tests with the loopback interface
> increasing the MTU over the 65535 byte limit.
> I was really surprised to see that a simple scp onto the ::1 address
> systematically blocked after transferring about 2,4 MB.
> My interpretation of this behavior is that the current IPv6 kernel layer
> does not support Jumbograms at all. Am I wrong ?
> If that's not the case, what could then the right interpretation of this
> issue ?
> And whenever I'm right, is there any plan to support this feature in a
> near future ?

IPv6 should handle the reception of jumbo frames quite fine, even the UDP size
override IIRC. But there is no support for large outgoing UDP frames, and I
currently don't know about TCP-MSS override works.

I guess you should be able to send jumbos with rawsocket if you attach the
dsthop header manually, but I have never tried it (maybe it will get blocked
by some check in ip6_output, HDRINCL and H-b-H option setsockopt could work
also).

I currently don't see the need for that option if no one also takes care about
UDP and TCP paths, so I guess support is coming as soon as someone cares. ;)

Greetings,

  Hannes
