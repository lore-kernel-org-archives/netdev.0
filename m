From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH v2] usbnet: do not count empty skbs as errors in rx_process()
Date: Sat, 11 Sep 2010 12:07:59 -0700 (PDT)
Message-ID: <704982.67431.qm@web180312.mail.gq1.yahoo.com>
References: <201009102336.00722.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009102336.00722.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- On Fri, 9/10/10, Ondrej Zary <linux@rainbow-software.org> wrote:

> From: Ondrej Zary <linux@rainbow-software.org>
> Subject: [PATCH v2] usbnet: do not count empty skbs as errors in rx_process()

NAK to this backwards-incompatible change.

At this point there's no way to know how many
drivers it breaks ... I do know that counting
such SKBs as errors has previously turned up
link-level errors, and thus led to bugfixes.


> If rx_fixup() returns an empty skb
> (because it consumed all data inside),

The canonical reason the SKB would be empty is
because after rx_fixup() removed all header and
trailer data, there was no packet body left.
Which is likely a link error, and has been
worth accounting as such in the past (turned up
bugs on TX or RX sides).

> do not count it as error.
> 
> This is needed for cx82310_eth.

I'd far rather see that driver fixed, than see
the core usbnet framework broken to avoid such
fixes to a very new driver ...
