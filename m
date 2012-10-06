From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined
 reference to `pch_ch_control_write'
Date: Sat, 6 Oct 2012 16:56:35 +0200
Message-ID: <20121006145634.GA2276@netboy.at.omicron.at>
References: <20121006075954.GA29618@localhost>
 <50701EEC.7080805@linux.intel.com>
 <20121006.092207.1280541690613202532.davem@davemloft.net>
 <50703B1B.2040705@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fengguang.wu@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38476 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab2JFO4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 10:56:46 -0400
Content-Disposition: inline
In-Reply-To: <50703B1B.2040705@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 06, 2012 at 10:07:23PM +0800, Haicheng Li wrote:
> 
> IMHO, the reason why the dependency of PCH_PTP becomes so tricky is
> that the code of these two modules call the functions of each other
> (bad code structure?).

Yes, that is the source of the problem. I don't recall how this habit
of having the PTP option as a module got started (and I hope it wasn't
me), but I think the right way to handle this option is with a simple
boolean connected to ifdefs for the MAC driver.

Come to think of it, it may have all started with the gianfar ptp
module. In principle, the time stamping function of a MAC driver can
be completely separate from the clock function, and indeed that is how
the pair of gianfar drivers work.

But for other hardware, it might not be practical to keep the
functions separate, and in that case I would say, just keep it as one
driver.

Thanks,
Richard

PS It looks like no one is really looking after this PCH thing, so
does anyone want to send me a board so I can take care of it? Let me
know off list.
