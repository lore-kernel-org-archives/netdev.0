From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Tue, 2 Jun 2009 23:38:29 +0930
Message-ID: <200906022338.30618.rusty@rustcorp.com.au>
References: <200905292344.56814.rusty@rustcorp.com.au> <1243885642.22917.35.camel@pohly-MOBL> <20090602.002553.143476036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@intel.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, divy@chelsio.com,
	rolandd@cisco.com, xemul@openvz.org, dcbw@redhat.com,
	libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49890 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbZFBOLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 10:11:37 -0400
In-Reply-To: <20090602.002553.143476036.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Jun 2009 04:55:53 pm David Miller wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Mon, 01 Jun 2009 21:47:22 +0200
>
> > On Fri, 2009-05-29 at 23:44 +0930, Rusty Russell wrote:
> >> This patch adds skb_orphan to the start of dev_hard_start_xmit(): it
> >> can be premature in the NETDEV_TX_BUSY case, but that's uncommon.
> >
> > Would it be possible to make the new skb_orphan() at the start of
> > dev_hard_start_xmit() conditionally so that it is not executed for
> > packets that are to be time stamped?
> >
> > As discussed before
> > (http://article.gmane.org/gmane.linux.network/121378/), the skb->sk
> > socket pointer is required for sending back the send time stamp from
> > inside the device driver. Calling skb_orphan() unconditionally as in
> > this patch would break the hardware time stamping of outgoing packets.
>
> Indeed, we need to check that case, at a minimum.
>
> And there are other potentially other problems.  For example, I
> wonder how this interacts with the new TX MMAP af_packet support
> in net-next-2.6 :-/

I think I'll do this in the driver for now, and let's revisit doing it 
generically later?

Thanks,
Rusty.
