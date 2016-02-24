From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Tue, 23 Feb 2016 16:53:40 -0800
Message-ID: <CALx6S35_vaAp9SWmh_SrLteZJxZ0eH1i+tp=2K7x3Que7h8wsQ@mail.gmail.com>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<56CC94D9.4030308@hpe.com>
	<56CC9914.5010506@solarflare.com>
	<20160223.130826.608797488173024832.davem@davemloft.net>
	<56CCBF22.6020904@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hpe.com>,
	Jesse Gross <jesse@kernel.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33637 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbcBXAxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 19:53:41 -0500
Received: by mail-io0-f182.google.com with SMTP id z135so11072025iof.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 16:53:41 -0800 (PST)
In-Reply-To: <56CCBF22.6020904@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [ I really hope we can figure out a way not to change IP IDs, because I think
> an inverted version of Tom's generic TSO could also work as a generic h/w GRO
> accelerator.  In its simplest form, the hardware just remembers the previous
> packet, then gives us the length of the common prefix.  If that ends four bytes
> into a TCP header, then the packet is a candidate for GRO; otherwise not.  I
> haven't worked out all the details yet, but it's clear that non-constant IP IDs
> would cause problems.  (If it's only the innermost IP ID that's changing, we
> can probably still cope, but the performance gain will be less and the
> implementation could start to get ugly.) ]

That's an interesting idea. This should work in IPv6 now and nearly
all encapsulation protocols (GRE w/ csum doesn't work this way for
instance), the logic to just match to a GRO state would be as simple
as comparing packet hashes and then do a memcmp over the headers. For
IPv4 maybe do a masked compare-- we still need to validate the header
checksum but that is easily checked without checksumming over the
whole header by just adding in the diff in the dynamic fields (i.e.
something like C_new == C_Old + (IP_ID_new - IP_ID_old)

Tom

>
> --
> -Ed
>
> [1] http://lxr.free-electrons.com/source/drivers/net/slip/slhc.c#L425
