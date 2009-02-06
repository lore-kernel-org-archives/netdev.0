From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: TX pre-headers...
Date: Fri, 6 Feb 2009 10:53:46 -0800
Message-ID: <200902061053.47722.inaky@linux.intel.com>
References: <OF39F6FFF6.453811EF-ON80257555.003A4714-80257555.003B50C2@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbZBFSyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 13:54:04 -0500
In-Reply-To: <OF39F6FFF6.453811EF-ON80257555.003A4714-80257555.003B50C2@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 February 2009, Steve.Glendinning@smsc.com wrote:
> David Miller <davem@davemloft.net> wrote on 06/02/2009 09:41:07:
> > Some NIC hardware wants a pre-header pushed in front of the packet
> > data on transmit.
> >
> > When routing or bridging this will cause a reallocation of skb->data
> > on every packet forwarded because there will only be NET_IP_ALIGN
> > space reserved at the head by the device receive path.
> >
> > NIU is one such NIC and I only noticed this because of some things I
> > saw in some of Robert Olsson's routing stress test oprofile dumps.
>
> Many of the usbnet drivers do this as well - for example smsc95xx needs
> either 8 or 12 bytes for its pre-header (depending whether tx checksum
> offload is enabled) and does this in its tx_fixup:

The wimax i2400m has a similar thing, but on top, it requires packets to
be coalesced and then yet another header with packet descriptors 
has to be added to them.

(header  pld0 pld1 pld2...padding pl0 pl1 pl2....)

pld - payload descriptor
pl - payload

Each IP packet payload has a prefix header too in the payload.

So it would not be able to take advantage of this (using a FIFO right now).
I wanted to explore doing all that coalescing using a sg vector, but 
until the USB and SDIO stacks support it without too much overhead, is 
not worth the effort.


-- 
Inaky
