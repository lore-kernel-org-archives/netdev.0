From: Dan Williams <dcbw@redhat.com>
Subject: Re: WAN device configuration, again...
Date: Wed, 28 Oct 2009 09:03:08 -0700
Message-ID: <1256745788.3850.31.camel@localhost.localdomain>
References: <m3d447hcks.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738AbZJ1QDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 12:03:06 -0400
In-Reply-To: <m3d447hcks.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 14:28 +0100, Krzysztof Halasa wrote:
> Hi,
> 
> I'm currently at final stages of "producing" two WAN drivers and there
> is one thing to solve: they have really complex options. It's no longer
> a V.35 with ca. 4 clock modes, a clock rate and few encodings etc. They
> need many options unique to each driver/board. I think I need a more
> capable interface to configure the devices than the current ioctl-based
> one.
> 
> I think of something:
> - using netlink or similar interface

If you're doing a new config interface, I'd suggest netlink like the
wireless guys did to replace WEXT with cfg80211.  Using netlink makes
your interface easily available from programs/libraries without having
to screenscrape anything.  If you want some advice on netlink API stuff,
ask Johannes Berg.

Dan

> - with potentially unlimited "payload" size (data may be transfered in
>   smaller packets)
> - the "command" and "response" should be variable-length ASCII-based,
>   instead of fixed structures. This way I don't have to duplicate all
>   option handling in userspace, only the specific driver has to know
>   about them.
> 
> Comments? Perhaps there is already an example?
> Should I use something else?
> 
> I also thought about using /sys read/write calls, but I'm not sure it's
> a good idea.

