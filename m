From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Mon, 9 Nov 2009 09:23:40 -0800
Message-ID: <469958e00911090923s7688bb78i18c7102195be6f9b@mail.gmail.com>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>
	 <469958e00911061112y4d2d746cq93d90abfd6df7ec1@mail.gmail.com>
	 <1257535875.2610.15.camel@ppwaskie-mobl2>
	 <20091107144938.82957125.billfink@mindspring.com>
	 <4AF6029F.6020403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bill Fink <billfink@mindspring.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:60026 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbZKIRXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 12:23:35 -0500
Received: by pwi3 with SMTP id 3so739851pwi.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 09:23:41 -0800 (PST)
In-Reply-To: <4AF6029F.6020403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 7, 2009 at 3:28 PM, Rick Jones <rick.jones2@hp.com> wrote:
>
> At the risk of typing words into someone's keyboard, I interpreted it as
> suggesting using the filtering language of netfilter or something similar,
> not necessarily netfilter itself?
>

Correct, a netfilter-friendly interface to the driver could be invoked by
lower-overhead entities that netfilter and the driver would not care.

However the real goal would be to still use netfilter, which would become
a low-overhead entity if it could delegate 90% of the rules it enforced to
smart hardware.

The fundamental suggestion is to start with a filter specification that is
clearly too rich for any Ethernet device, and let the Ethernet devices
decide how quickly they want to catch up. As opposed to standardizing
how smart a smart Ethernet device is and potentially leaving some hardware
capabilities made inaccessible.

I'll point out that once you assume an Ethernet Device is capable of doing
TCP/UDP checksum offload and LSO/LRO then clearly you have recognized
that it is an L4 aware device. Designing its filtering rules as though it were
an L2-only device does not allow it to take advantage of the L4 parsing that
many/most Ethernet NICs already do.
