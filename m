From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Thu, 8 May 2014 10:32:47 +0200
Message-ID: <20140508083247.GA5719@cpaasch-mac>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
 <20140507.013820.1357850416047414291.davem@davemloft.net>
 <CAE1zotJXpM+crFYE8-95G6s77BGvWF0LUUNgvCjQPcr-nbmzAA@mail.gmail.com>
 <09b16b4c1a6147f8aa4137e2c50e2e74@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "octavian.purdila@intel.com" <octavian.purdila@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37408 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaEHIcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 04:32:53 -0400
Content-Disposition: inline
In-Reply-To: <09b16b4c1a6147f8aa4137e2c50e2e74@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/14 - 16:48:59, David Miller wrote:
> From: Octavian Purdila <octavian.purdila@intel.com>
> Date: Wed, 7 May 2014 10:30:23 +0300
> 
> > On Wed, May 7, 2014 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
> >>
> >> From: Octavian Purdila <octavian.purdila@intel.com>
> >> Date: Tue,  6 May 2014 21:05:24 +0300
> >>
> >> > Pardon the rough patch, but I hope it is enough to get some feedback
> >> > on the overall approach.
> >>
> >> Sorry I don't like this.
> >>
> >> Walking a linked list unnecessary is going to add overhead to every
> >> single packet transmission.  I think more people want our TCP stack to
> >> be fast (everyone) than those who want option processing to be
> >> abstracted enough to be modular (you).
> >>
> >> Just make the intrusive changes, they are necessary as they force you
> >> to think fully about how one option might interact with another.
> >>
> > 
> > Unfortunately skb_tcp_cb does not have enough space to hold
> > information for new large options. To work around that, the MPTCP
> > implementation is pushing the option data in the skb and then
> > occasionally uses the following when the pskb_copy is used:
> 
> Why not deal with the problem directly by trying to find a way to
> compress the existing use of skb_tcp_cb() so that there is actually
> the amount of space you need?

It might be possible to replace accesses to end_seq by calculating (seq + len + fin/syn)
That way, we gain 4 bytes. Would this be acceptable?

And union tcp_flags/ip_dsfield as suggested in b82d1bb4fd206 (tcp: unalias
tcp_skb_cb flags and ip_dsfield).



Cheers,
Christoph
