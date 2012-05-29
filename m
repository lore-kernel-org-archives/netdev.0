From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fwd: Ethtool not displaying ntuple/nfc rule settings
Date: Tue, 29 May 2012 18:55:20 +0100
Message-ID: <1338314120.2645.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAFZv140-yrrDmD_H3ySEfJOL7Yp3syGt-VCNXaOi64nzucp5xA@mail.gmail.com>
	 <CAFZv1415XPt+7v3xo6BR86cRKPju7QV7NQMAzS-O21TqvGBgBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: TJ Johnson <tjjohnson10200@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43060 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754517Ab2E2Rz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 13:55:27 -0400
In-Reply-To: <CAFZv1415XPt+7v3xo6BR86cRKPju7QV7NQMAzS-O21TqvGBgBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 10:55 -0600, TJ Johnson wrote:
> Sorry for the double send. Had to convert to plain text as I received
> failure messages.
> 
> ---------- Forwarded message ----------
> From: TJ Johnson <tjjohnson10200@gmail.com>
> Date: Tue, May 29, 2012 at 10:36 AM
> Subject: Ethtool not displaying ntuple/nfc rule settings
> To: netdev@vger.kernel.org, bhutchings@solarflare.com
> 
> 
> Hi,
> 
> Not sure if this is even the right place to ask this, so feel free to push
> me somewhere else if necessary. I am using ethtool's -U option to set up
> rules for an ixgbe device. That part seems to work great. However I am
> unable to check the currently configured rules once they are in place.
> 
> ethtool -u DEVNAME produces this:
> Cannot get RX rings: Operation not supported
> rxclass: Cannot get RX class rule count: Operation not supported
> RX classification rule retrieval failed
> 
> ethtool -n DEVNAME rx-flow-hash udp4 produces this:
> Cannot get RX network flow hashing options: Operation not supported
[...]
> The OS is SUSE Linux Enterprise Server 11 using a custom 2.6.36 kernel.
> 
> Any Ideas as to what the problem might be? Or how I can solve the issue?

This version of the ixgbe driver implemented the n-tuple interface,
which has since been removed in favour of the NFC rules interface.  It
was switched to the new interface in Linux 3.1.

ethtool supports setting rules through either interface (automatically)
but can only read them back through the NFC rules interface.  The
n-tuple interface did support reading rules but the information returned
was unreliable: it would not necessarily match the hardware state.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
