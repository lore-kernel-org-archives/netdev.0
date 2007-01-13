From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sat, 13 Jan 2007 14:30:33 -0500
Message-ID: <20070113143033.fi804so8ok04wc4k@webmail.spamcop.net>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701131509.26877.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:50963 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1422761AbXAMTaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jan 2007 14:30:35 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701131509.26877.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Buesch <mb@bu3sch.de>:

> I looked more closely at it, but I really can't see why it oopses.
> Any idea what's happening there?

I haven't looked at the code yet, but I tried to locate the bad commit.  I tried
commit a13f85d8a8eb40dfd157ab78c2fb91b5765b7b9d, which is your last merge, just
before the SSB changes.

The kernel doesn't oops anymore!  But it doesn't connect either.  I reconfigured
the AP to use WPA-PSK with TKIP.  MadWifi works with it, but bcm43xx fails in
the same configuration.  The wireless-dev tip has the same problem.

So, the oops was introduced in the transition to the new SSB. 
bcm43xx_setup_dmaring(), which appears in the stack dump, is affected by the
patch.

I'll try to look closely at the changes.  My immediate suspect is that we have
too many different fields called "dev".  All it takes is one cast to hide a
horrible mistake.  Although I think it would have affected you as well (unless
it's casts to/from integers, something that won't be a problem on 32-bit
kernels).

> Well, ok. So it should work in my tree, too, once we fixed the DMA oops.

You mean there is a reason for me to think that your changes would fix
accociation to the AP?

I have never had any success with any d80211 based driver, so I have a strong
suspicion that I'm doing something wrong.  I'll try to report a clear-cut case
with a less problematic driver in a separate thread.

--
Regards,
Pavel Roskin
