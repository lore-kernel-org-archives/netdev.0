From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 18:30:37 -0400
Message-ID: <200904071830.38081.rgetz@blackfin.uclinux.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <1239116251.14392.133.camel@calx> <a24804730904071439g4cc1779bi1ebaf814d370708c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chris Peterson" <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:27927 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbZDGW3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 18:29:19 -0400
In-Reply-To: <a24804730904071439g4cc1779bi1ebaf814d370708c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 7 Apr 2009 17:39, Chris Peterson pondered:
> 1. Are there any new add_*_randomness() functions that could be added?

I can think of - USB, serial, SDIO - but if any are heavily loaded with 
constant data - their randomness reduces, and becomes less useful. if it is 
the normal use case - then these might be better - but it is a function of 
the local users's use of the device - and is not remotely attackable.

> Some userspace daemons like EGD (running as root) feed random system
> info (e.g. vmstat) into /dev/random. But how many Linux distros
> actually run entropy-gathering daemons by default?

Not many that I can find.

> Would /dev/random 
> be more secure if entropy-gathering daemons were replaced with new
> kernel functions like add_vmstat_randomness() or add_ps_randomness()?

on embedded and server - it is likely most of ps (except load) will be pretty 
stable - even vmstat - might be on more stable than you think on embedded - 
which starts processes, allocates memory, and then just runs forever.....

> 2. Are there any other functions that could be calling the existing
> add_*_randomness() functions? Currently:
> 
> * add_input_randomness() is called from input_event().

Could be added in the serial core? usb? spi? i2c?

> * add_interrupt_randomess() is called from handle_IRQ_event() if
>    IRQF_SAMPLE_RANDOM is set.
> * add_disk_randomness() is called from blk_end_io() and __blk_end_request().
