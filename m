From: Paul Mackerras <paulus@samba.org>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Sun, 15 Apr 2007 02:49:28 +1000
Message-ID: <17953.1560.855914.274514@cargo.ozlabs.ibm.com>
References: <9a8748490704100425t34ebafcdq866a923df80b9aca@mail.gmail.com>
	<19061b0b0704112218j13688c16xc755d66147f8fe6a@mail.gmail.com>
	<461DC70B.4000500@trash.net>
	<20070413.161635.26523891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41024 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbXDNQta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2007 12:49:30 -0400
In-Reply-To: <20070413.161635.26523891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:

> > It seems we fail to reserve enough headroom for the case
> > buf[0] == PPP_ALLSTATIONS and buf[1] != PPP_UI.
> > 
> > Can you try this patch please?
> 
> Any confirmation of this fix yet?

Indeed, ppp_async doesn't handle that case correctly.

RFC 1662 says:

      The Control field is a single octet, which contains the binary
      sequence 00000011 (hexadecimal 0x03), the Unnumbered Information
      (UI) command with the Poll/Final (P/F) bit set to zero.

      The use of other Control field values may be defined at a later
      time, or by prior agreement.  Frames with unrecognized Control
      field values SHOULD be silently discarded.

In what situation were we getting the frames that cause the problem?

I didn't see the patch (the message that this is a reply to is the
first one that I have seen in this thread), so I can't comment on it.

Paul.
