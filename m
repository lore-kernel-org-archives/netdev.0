From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Thu, 14 Mar 2013 21:58:14 +0000
Message-ID: <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54856 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab3CNV6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 17:58:17 -0400
In-Reply-To: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 13:37 -0700, Andy Lutomirski wrote:
> (I'm on Ubuntu's 3.5.0-23, but I haven't seen anything that would
> change this behavior in newer kernels.)
> 
> I have a myri10ge device that's attached to a port mirror.  It runs
> tcpdump.  Most of the traffic I'm capturing has another machine
> attached to this switch as an endpoint.  That machine is considerably
> faster than the machine doing the capturing.
> 
> My captures show nasty artifacts: packets are reodered between a given
> flow and the other direction of the same flow.  The nasty case is when
> an ACK shows up before the packet that it's acking.  This thoroughly
> screws up Wireshark's TCP sequencing analysis.  Turning off LRO and
> GRO fixes it.
> 
> Clearly, since this interface doesn't actually have an IP address,
> there's no good reason to keep GRO and LRO on.  Nonetheless, it would
> be nice if GRO didn't coalesce packets when there's an intervening
> packing in the other direction on the same flow.  Can this be done
> cheaply?

No, it would not be cheap.

You'll probably have to disable GRO, LRO and also RSS (unless you can
configure the RSS hash function to produce the same result for both
directions of a flow).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
