From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 10:03:46 -0700
Message-ID: <20060510170346.GG23571@instant802.com>
References: <200605061401.01795.IvDoorn@gmail.com> <20060510124217.0d3810bd@griffin.suse.cz> <200605101553.52031.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-5.dex002.intermedia.net ([64.78.21.20]:44056 "EHLO
	dhost002-5.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964991AbWEJRDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 13:03:49 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200605101553.52031.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 10, 2006 at 03:53:48PM +0200, Ivo van Doorn wrote:

> I think the problem is what the dscape exactly expects the driver to do when
> add_interface() is called by the stack. When that call has finished, does the stack
> expects the radio to be enabled, or should it instruct the driver to enable the radio later
> on through a field in the config structure.

I think the current expectation is for the interface to be set into
enabled state at this point.

> What currently happens in rt2x00 (Which might not be doing what the stack expects)
> is that when add_interface() is called the radio remains off untill open() is called or
> radio_enabled has been set in the config structure.

We used radio_enabled (or well, the previously used name adm_status) as
a "soft disable", i.e., the radio hardware was mostly enabled, but no TX
or RX happened. This could, e.g., mean masking out interrupts and/or
disabling receive part of the radio.

This has been used to provide a mechanism for disabling the radio
without having to set the interface down, i.e., without causing IP
addresses to be dropped or bridging status changed.

-- 
Jouni Malinen                                            PGP id EFC895FA
