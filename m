From: Baruch Even <baruch@ev-en.org>
Subject: Re: Unexpected Acknowledgement / Stalled Connections
Date: Mon, 5 Feb 2007 07:37:03 +0200
Message-ID: <20070205053703.GC25760@galon.ev-en.org>
References: <82e4877d0702041431p555e644et35845db674304403@mail.gmail.com> <82e4877d0702041456u5d30d32bs41233048a1833d59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:59882
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbXBEFhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 00:37:06 -0500
Content-Disposition: inline
In-Reply-To: <82e4877d0702041456u5d30d32bs41233048a1833d59@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Parag Warudkar <parag.warudkar@gmail.com> [070205 00:57]:
> On 2/4/07, Parag Warudkar <parag.warudkar@gmail.com> wrote:
> >I am running 2.6.20 and have trouble with stalled connections. For
> >instance, if I try to download a debian ISO image using wget, the
> >connection runs fine for few seconds and then stalls for ever.
> >
> >In my router logs I see a ton of messages like the below -
> >
> >[INFO] Sun Feb 04 17:22:03 2007 Blocked incoming TCP packet from
> >192.168.0.174:34090 to 130.239.18.138:80 with unexpected
> >acknowledgement 3269301836 (expected 3269343453 to 3269408989)
> >
> >Where 192.168.0.174 is my laptop running FC6 and kernel 2.6.20 and
> >130.239.18.138 is whatever cdimage.debian.org resolves to atm.
> >
> >What's going on here? Any TCP/IP tunable that I can set/turn on/off to
> >prevent this from happening?
> 
> Turning tcp_sack off seems to cure it. Turning it on again makes the
> connections stall. Seems like the D-Link router doesn't like the SACKs
> linux sends?

You can also try to disable tcp_window_scaling.

Can you provide a tcpdump trace of the connection? Traces with and
without SACK would be appreciated, also a trace with SACK but without
window scaling would be useful. I only need the headers of the packet so
-s 60 (the default) will be fine.

There was a change in 2.6.20 that I put but it should only have affected
the sender side and even then only the way it interpreted the data and
not things it sent on the wire.

Trying the dl with previous kernels can also help, if only to try and
pinpoint where things went bad, assuming it is in the kernel. This
sounds like a bad implementation of ACK window checks that ICSA requires
for firewall product certification.

Baruch
