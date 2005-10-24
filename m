From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Mon, 24 Oct 2005 17:57:53 -0400
Message-ID: <20051024215751.GH28212@tuxdriver.com>
References: <09122005104858.332@bilbo.tuxdriver.com> <4325CEAB.2050600@pobox.com> <20050912191419.GB19644@tuxdriver.com> <435D53AE.3020401@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751328AbVJXV6E@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <435D53AE.3020401@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2005 at 02:35:42PM -0700, Ben Greear wrote:

> It doesn't matter too much to me either way, but I'd like for there to
> be a precisely documented definition for the various net-stats so that
> I can correctly show the values to user-space (I can certainly add 
> rx_discards
> to rx_errors for a 'total rx errors' value, but I need to know whether
> rx_discards is already in rx_errors to keep from counting things twice.)

My opinion is that:

	-- rx_errors should count all "on the wire" hardware errors;

	-- rx_missed_errors should count frames w/ no "on the wire"
	errors that cannot be received by the hardware (generally
	due to lack of DMA bufers); and,

	-- rx_discards should count frames dropped by the kernel
	after successful reception by the hardware.

I do _not_ think rx_missed_errors should be counted as part of
rx_errors, but I could be persuaded otherwise.

> Jeff:  Could you lay down the law somewhere in the Documentation/
> directory and then let us start fixing any driver that does it differently?

It does seem like a netdev stats clarification doc would be
appropriate.  Does anyone have the beginnings of this?

John
-- 
John W. Linville
linville@tuxdriver.com
