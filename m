From: David Miller <davem@davemloft.net>
Subject: Re: ARP resolving for switch drivers
Date: Fri, 27 Feb 2015 17:26:49 -0500 (EST)
Message-ID: <20150227.172649.2209140275022350959.davem@davemloft.net>
References: <CAE4R7bDnrMZSsZeZmYkT8HhkXUpgnedBo8VX5iEtyJmzJ7gV5A@mail.gmail.com>
	<54EEB5A1.1000706@cumulusnetworks.com>
	<CAE4R7bBxHs9aGf1tupH6d+MNQ9m5zzzbdrMYcmmnxe5gtH2Q3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	shm@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbbB0W0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:26:51 -0500
In-Reply-To: <CAE4R7bBxHs9aGf1tupH6d+MNQ9m5zzzbdrMYcmmnxe5gtH2Q3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Thu, 26 Feb 2015 04:03:20 -0800

> I don't have a better label at this time.  "external" for both FDB and
> FIB seems consistent to me since in both cases the kernel's DB (FDB or
> FIB) has entries marked with "external" meaning they exist also in
> some offload device's DB (FDB or FIB), and the device will offload the
> fwd processing from the kernel.

I think allowing explicit control of entry loading into HW is a totally
separate piece of work from initial L3 offload support.

I want to see the most stupid implementation possible at the beginning.

Which means load entries until we cannot any more, and when we reach
that limit flush the entire HW table, stop offloading, and do
everything in software.

If you try to take the next step and allow for fine grained control,
and most intelligent policy on the kernel side of things, we're going
to go back and forth forever.

Get the basic stuff in now, and then we can argue about how to do the
rest meanwhile.
