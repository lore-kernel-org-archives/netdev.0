From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: time stamping packets (on Rx side)
Date: Fri, 16 Mar 2012 08:10:39 +0100
Message-ID: <20120316071039.GC2199@netboy.at.omicron.at>
References: <CAAsGZS4OvqyRr-1vvTzW5+Lx5007tuwP5GsZHRDXEOY4q1Mw1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57252 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032320Ab2CPHKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 03:10:46 -0400
Received: by wibhj6 with SMTP id hj6so390908wib.1
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 00:10:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS4OvqyRr-1vvTzW5+Lx5007tuwP5GsZHRDXEOY4q1Mw1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 02:13:01PM -0400, chetan loke wrote:
> Hello,
> 
> So with the (ptp clock support)PHC in place, some apps can use it as a
> reference clock. But if I'm trying to debug/analyze packets(by TAP'ing
> a link) using linux then I might still have a problem. Does Intel (or
> any adapter with 1588 support) have the capability to time stamp the
> packet on the NIC and not on the host side?  Because if we time stamp
> on the host side then it all depends when we drain Port0 and Port1's
> Rx descriptors of the dual-port NIC. It's quite possible that we might
> see reply before request. But if the pkt was stamped by the NIC then
> we know for sure which came first.

Not sure what you mean by NIC/host side.

But, yes, time stamping every received packet in the MAC is a nice
feature. Be careful when choosing your hardware, since many cards with
PTP hardware time stamping *only* stamp the PTP packets.

Some cards can provide a time stamp in the frame or in its control
block, and thus time stamp every packet. The Intel 82580 can do this,
and so can the Freescale gianfar controller (well, some of them,
anyhow).

HTH,
Richard
