From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 09:20:45 -0700
Message-ID: <20060515162045.GA10717@instant802.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <1147703855.2193.47.camel@localhost.localdomain> <200605151712.23639.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Mark Wallis <mwallis@serialmonkey.com>, netdev@vger.kernel.org,
	David Zeuthen <davidz@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-9.dex002.intermedia.net ([64.78.21.63]:58631 "EHLO
	dhost002-9.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932251AbWEOQYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 12:24:12 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200605151712.23639.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 05:12:20PM +0200, Ivo van Doorn wrote:

> Well I would think it is cleaner to inform userspace that the button is pressed
> and let userspace sort out what exactly should happen.
> But I doubt it will be a good idea when the driver is sending and event _and_
> disabled the radio. It could be that the user wants something to be done
> before the radio is being disabled.

Some hardware designs disable the radio in hardware, some don't.. In
other words, the behavior would not be consistent between hardware
designs unless the radio would be disabled unconditionally in
software-processed case. I would like to be able to trust on the
rfkill to really kill the radio regardless of whether the user space
mechanism is in place or not, i.e., I see this as a function that can be
used to disable radio in environments were use of wireless devices is
not allowed for some reason.

Sending an event to user space would be a good additional indication
that the radio was disabled. If user space wants to do something first,
I would think that doing this with full software control (i.e., not
depending on any particular hardware button and just having a UI
mechanism for triggering this) would allow more consistent behavior.

-- 
Jouni Malinen                                            PGP id EFC895FA
