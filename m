From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 02/29] wimax: headers for kernel API and user space interaction
Date: Mon, 8 Dec 2008 13:22:13 -0800
Message-ID: <200812081322.14089.inaky@linux.intel.com>
References: <cover.1228759689.git.inaky@linux.intel.com> <b0c3e76927519e8e46f9de8927207257159a70f0.1228759689.git.inaky@linux.intel.com> <1228766734.22164.127.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56931 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752200AbYLHVW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 16:22:29 -0500
In-Reply-To: <1228766734.22164.127.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 December 2008, Johannes Berg wrote:
> On Mon, 2008-12-08 at 11:09 -0800, Inaky Perez-Gonzalez wrote:
> > +/*
> > + * Generic NetLink operations
> > + *
> > + * Most of these map to an API call; _OP_ stands for operation, _RP_
> > + * for reply and _RE_ for report (aka: signal).
> > + */
> > +enum {
> > +	WIMAX_GNL_OP_MSG_FROM_USER,	/* User to kernel message */
> > +	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */
>
> Since you're going to do these iwpriv-style things anyway no matter what
> I say :) can we at least get it to use netlink attributes *within*
> these? In i2400m you define a new protocol that pretty much looks

I am paying attention to what you say :) 

I don't want to have this iwpriv like thing for ever; remember that is an stop
gap for the time being as (a) we have no other reference hardware and (b)
our user space is still evolving.

We already started discussing in the wimax list (with Juuso, from Nokia) how
a NAP-based API should look. My plan is to start working on it in the New
Year, after I come back from vacation.

> identical to netlink attributes, but just a bit different:
> > + * This is the control protocol used by the host to control the i2400m
> > + * device (scan, connect, disconnect...). This is sent to / received
> > + * as control frames. These frames consist of a header and zero or
> > + * more TLVs with information. We call each control frame a "message".
>
> Or isn't that what is contained in the WIMAX_GNL_MSG_DATA attribute? You
> can nest netlink attributes, that would already make it a whole lot more
> regular, rather than defining your own sub-protocol.

It is, but that is host-to-device (or better, host-to-firmware protocol), the
device's specific protocol. I have no say on how it is. It is quite similar,
in any case, as it is TLV based.

When the kernel level API is in place, a command sent over generic netlink 
will be translated by the driver into a protocol-specific message and sent
to the device.

-- 
Inaky
