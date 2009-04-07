From: Chris Peterson <cpeterso@cpeterso.com>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 14:39:05 -0700
Message-ID: <a24804730904071439g4cc1779bi1ebaf814d370708c@mail.gmail.com>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>
	 <1239044483.14392.55.camel@calx>
	 <200904070716.25846.rgetz@blackfin.uclinux.org>
	 <1239116251.14392.133.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Robin Getz <rgetz@blackfin.uclinux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:54278 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbZDGVjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 17:39:08 -0400
In-Reply-To: <1239116251.14392.133.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Are there any new add_*_randomness() functions that could be added?
Some userspace daemons like EGD (running as root) feed random system
info (e.g. vmstat) into /dev/random. But how many Linux distros
actually run entropy-gathering daemons by default? Would /dev/random
be more secure if entropy-gathering daemons were replaced with new
kernel functions like add_vmstat_randomness() or add_ps_randomness()?

2. Are there any other functions that could be calling the existing
add_*_randomness() functions? Currently:

* add_input_randomness() is called from input_event().
* add_interrupt_randomess() is called from handle_IRQ_event() if
IRQF_SAMPLE_RANDOM is set.
* add_disk_randomness() is called from blk_end_io() and __blk_end_request().
