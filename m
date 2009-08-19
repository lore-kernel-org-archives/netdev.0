From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: AX.25 devices on USB ?
Date: Wed, 19 Aug 2009 22:48:47 +0100
Message-ID: <20090819224847.5b2491a7@lxorguk.ukuu.org.uk>
References: <20090819204125.GB30210@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ax25@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:51872 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753143AbZHSVre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:47:34 -0400
In-Reply-To: <20090819204125.GB30210@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I do think that it needs to be some sort of "Communications Device Class"
> thing, but what kind of ?  I really do not want to put virtual serial ports
> and KISS encapsulation in there...  (Those not familar with Radio Amateur
> protocols, KISS is variation of SLIP with a hook to handle couple link-layer
> control functions, plus multiplexing multiple devices on single serial port.)

The KISS serial interface is also used for all sorts of configuration
functions on some devices. Assuming the congestion algorithms are done in
the USB device then you'd need a control interface and a network
interface of some sort.

> On USB CDC specification part 4.7 there is a table of "Data Interface Class
> Protocol Codes" -- and there code 31h: "HDLC" would probably be what engineer
> orders for all manner of radio amateur data protocols.
> (That use packets to begin with.)

AX.25 is basically LAP-B over HDLC but the bitstuffing is generally done
by the controller (hence the use of KISS etc). Not all amateur protocols
are HDLC - the Karn FEC encodings (Viterbi etc) for example.

> Any ideas ?

I would use ethernet. There are semi-standards for AX.25 over Ethernet
frames (BPQ) which Linux can talk. If you dump everything but BPQ protocol
frames and perhaps purloin another protocol id for control frames that
should give you everything you need without a line of Linux side kernel
code.

If you wanted to be really crazy then you could teach your firmware to
also re-encap/de-cap IP frames in ethernet format to/from AX.25 UI
headers and likewise for ARP, at which point it might even work on
Windows without a driver - at least for IP ;)

Alan
