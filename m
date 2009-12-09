From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: Q: netdev: generate kobject uevent on network events.
Date: Wed, 9 Dec 2009 13:54:09 -0500
Message-ID: <20091209185409.GD32273@kvack.org>
References: <20091209170251.GA11650@sig21.net> <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Stezenbach <js@sig21.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:50201 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814AbZLISyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 13:54:05 -0500
Content-Disposition: inline
In-Reply-To: <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2009 at 07:46:26PM +0100, Kay Sievers wrote:
> Can't, in some setups, these events happen at a rather high frequency?
> I heard of people running many hundreds of ppp interfaces on a single
> box acting as a DSL concentrator.

/me waves

Yes, DSL concentration is looking at tens of thousands to a hundred thousand 
interfaces on current hardware with 10G links.

> They state to already have trouble
> handling the amount of uevents generated on such boxes just for the
> "add/remove" events of all the interfaces if something goes wrong with
> the network. If we add more for state transitions, such events would
> probably need to be rate-limited. In general, uevents/udev are not
> really suitable for high-frequency events, and if such behavior can be
> expected, we might better stick with the current netlink interface.

Duplicating events in different delivery mechanisms seems pointless.  A 
simple netlink listener can be done in less than a hundred lines, so I don't 
see the need for the duplication.

		-ben
