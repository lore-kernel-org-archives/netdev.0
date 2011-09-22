From: David Lamparter <equinox@diac24.net>
Subject: Re: Introducing open source MSTP daemon
Date: Thu, 22 Sep 2011 18:39:40 +0200
Message-ID: <20110922163939.GB1012103@jupiter.n2.diac24.net>
References: <201109221727.33010.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alex Rozin <alexr@nbase.co.il>,
	Michael Rozhavsky <mike@nbase.co.il>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:46322 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab1IVQju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 12:39:50 -0400
Content-Disposition: inline
In-Reply-To: <201109221727.33010.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2011 at 05:27:32PM +0300, Vitalii Demianets wrote:
> Good day!
> I am happy to introduce open source MSTP daemon:
> http://sourceforge.net/p/mstpd
> 
> Of course due to current limitations of the Linux bridge code, namely:
>  - no integration with VLAN code
>  - no support of different FIDs (independent learning)
>  - no support of the per-MSTI port states

Yes... Linux kernel bridging code only implements 802.1D, even the mac
table is one-for-all-VLANs.

> this daemon is not very useful for the bare Linux box. It can work only with 
> support of specialized driver which talks to the MSTP-aware hardware (most of 
> the today ethernet switching parts are MSTP-aware and support FIDs and 
> per-MSTI port states).
> Nevertheless I hope to find some interest in my work. Maybe it will stimulate 
> in some way the integration of the Linux bridge and VLAN code, who knows? 
> From the IEEE point of view they are already merged, see 802.1Q-2005 which 
> incorporates previous editions of 802.1q and 802.1d and 802.1w/s.
> 
> Once again, all interested are welcome. Please review, criticize, test, 
> modify, patch, deploy and do other things :) Any kind of feedback is 
> extremely welcome :)

Very cool!

The code looks quite good to me (i've only looked at 2 files though ;).
Minor nitpicks:
 - hmac_md5 & epoll could maybe come from an external library. you're
   the 3810583th person to have code for that... libevent?
   OpenSSL/gnutls?
 - libnetlink.c is a copy from iproute2? since it is a fresh clean SVN,
   it's not easy to know whether you made changes. Can you put a note
   which version this is? Or maybe you can link it externally?
 - the "assign" macro and "boolFalse" in mstp.c are weird. I understand
   you want stricter type checking, but this makes the code somewhat
   odd to read. Maybe external tools can be used to do this checking
   (sparse, cppcheck, llvm's static analysis, ...)
 - what coding style is it? it's neither Linux kernel nor GNU :) - maybe
   reformat to Linux kernel style while it is still new.

I assume it works with current Linux kernel bridge code on a RSTP level?
The code looks considerably more maintainable than rstpd :) - I will try
running it later!


-David
