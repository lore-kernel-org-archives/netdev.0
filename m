From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Thu, 4 Oct 2012 08:12:14 -0700
Message-ID: <20121004081214.7f5a48fe@nehalam.linuxnetplumber.net>
References: <20121001223232.566037595@vyatta.com>
	<20121001223254.349753999@vyatta.com>
	<CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
	<20121003210220.5e74aa5d@nehalam.linuxnetplumber.net>
	<1349332490.16011.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55674 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965590Ab2JDPMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 11:12:52 -0400
In-Reply-To: <1349332490.16011.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Oct 2012 08:34:50 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2012-10-03 at 21:02 -0700, Stephen Hemminger wrote:
> 
> >
> > Since port is always a pair, there is no need to restrict range, unless
> > there was a broken firewall in the way. One bug there is that random32()
> > can return 0 which is not a valid port number.  A better fallback
> > would be a hash of the MAC header.
> 
> But using up to 65536 values for the port means that if vxlan traffic
> crosses a statefull firewall (eg netfilter with conntrack), this might
> need 65536 contexts/sessions.

This is UDP, there is no usable state to be found.
But as a practical matter it only needs to be wide enough to hit the
number of receive channels. Therefore even 64 is probably enough for
most people.

> So random32() is not needed.
> 
> What might be needed is additional parameters for a vxlan tunnel, to
> give an optional range for the source port.

It could be per vxlan without a lot of pain. or just derive it value
from existing ephermeral port range.
