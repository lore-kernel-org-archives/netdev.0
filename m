From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 13:49:25 -0700
Message-ID: <20130419134925.4981bdfc@nehalam.linuxnetplumber.net>
References: <20130419.155859.1092595631804890737.davem@davemloft.net>
	<20130419131632.31fce894@nehalam.linuxnetplumber.net>
	<1366403483.16391.59.camel@edumazet-glaptop>
	<20130419.163831.1434224426107133131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:63275 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab3DSUt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:49:57 -0400
Received: by mail-pd0-f169.google.com with SMTP id 14so603615pdc.14
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 13:49:57 -0700 (PDT)
In-Reply-To: <20130419.163831.1434224426107133131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Apr 2013 16:38:31 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Apr 2013 13:31:23 -0700
> 
> > On Fri, 2013-04-19 at 13:16 -0700, Stephen Hemminger wrote:
> > 
> >> I can not get line rate output with pktgen on existing kernels today.
> > 
> > I have no trouble saturating at line rate with pktgen, and using
> > multiqueue NIC.
> 
> +1
> 
> > I really hope we do not use pktgen as an argument for having netmap in
> > the kernel.
> 
> Me too.

I get 7Mpps (single queue) with ixgbe and pktgen.
Easily hit 14.8 Mpps (single queue) with netmap.

The real problem is that DPDK and netmap can do multiple packets per request
to driver. Right now their is one PCI bus transaction per packet with current
driver model.

But, I am not convinced that netmap is the right solution either, this is purely
an RFC to get some attention on doing better at small packet performance.
If you look at netmap right now, it has really ugly BSD wrapper code
and does lots of assumptions and bypassing of network stack; ie. fugly.
