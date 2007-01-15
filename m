From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 10:19:22 -0800
Message-ID: <45ABC5AA.1060307@intel.com>
References: <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <4.3.2.7.2.20070115091058.063866c8@www.n4comm.com> <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41576 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbXAOSTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 13:19:24 -0500
To: Harry Coin <hcoin@n4comm.com>
In-Reply-To: <4.3.2.7.2.20070115113616.03dcf4a8@www.n4comm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harry Coin wrote:
> Hello from Iowa.
> 
> Below please find a fix to the Wake On Lan function in the e100.c (intel 
> 10/100) driver.   With the original driver distributed in kernel 2.6.18 
> in debian etch, wake on lan did not work.   This was tested on 14 dell 
> optiplexes with built-in ethernet chips in a totally diskless 
> environment (initramfs / pxelinux).  All operations were normal save 
> wake on lan.

Oi,

I've done quite a bit of work especially on that since 2.6.18 and as far as I could see 
those changes fixed WoL, suspend/resume and netconsole, as was confirmed by Andrew 
Morton even.

Have you tried the version in 2.6.19?

> When WOL has been enabled with ethtools, the old driver assumes wrongly 
> that e100_configure will be called at least once with !netif_running.  
> Only in that instance will it set the chip to notice 'magic' wol packets 
> if the ethtools -s wol g has been called prior.
> 
> The old e100_down routine never does call e100_configure so that the 
> driver never does  turn off the 'disable WOL magic packet' bit.
> Neither does the .shutdown routine.   This fix tries to only enable the 
> WOL recognition only when e100_down is called for the last time
> before module unload or system shutdown, while leaving ifconfig down 
> untouched.    (testing for being run in the context of dev->stop).

that's exactly what my patches should fix as far as I can remember

> I have also submitted the above to the e1000 group at intel privately as 
> they are the 'maintainers', but this appears to be the only apropos open 
> group I thought to note he here as well.

I have not seen this patch before, care to Cc me to that? We also publically discuss 
e1000/e100 and ixgb issues on e1000-devel@lists.sourceforge.net. Feel free to Cc that list.

Cheers,

Auke
