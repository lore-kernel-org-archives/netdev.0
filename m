From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Enabling standard compliant behaviour in the Linux TCP
 implementation
Date: Tue, 16 May 2006 09:24:07 -0700
Message-ID: <20060516092407.68fbc205@localhost.localdomain>
References: <8dd26e70605160724j784cf538v59631cf571646f36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco@net.infocom.uniroma1.it,
	andrea.baiocchi@uniroma1.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30397 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751669AbWEPQYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 12:24:23 -0400
To: "Angelo P. Castellani" <angelo.castellani+lkml@gmail.com>
In-Reply-To: <8dd26e70605160724j784cf538v59631cf571646f36@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 May 2006 16:24:22 +0200
"Angelo P. Castellani" <angelo.castellani+lkml@gmail.com> wrote:

> Hi all,
> I'm a student doing a thesis about TCP performance over high BDP links
> and so about congestion control in TCP.
> 
> To do this work I've built a testbed using the latest Linux release (2.6.16).
> 
> Anyway I've came across the fact that Linux TCP implementation isn't
> fully standard compliant.
> 
> Even if the choices made to be different from the standards have been
> wisely thought, I think that should be possible to disable these
> Linuxisms.
> 
> Surely this can help all the people using Linux to evaluate a
> "standard" environment.
> 
> Moreover it permits to compare the pros&cons of the Linux
> implementation against the standard one.
> 
> So I've disabled the first two Linux-specific mechanisms I've found:
> - rate halving
> - dynamic reordering metric (dynamic DupThresh)
> 
> These're disabled as long as net.ipv4.tcp_standard_compliant=1 (default: 0).
> 
> However I don't exclude that there're more non-standard details, so I
> hope that somebody can point some more differences between Linux and
> the RFCs.
> 
> Moreover NewReno is implemented in the Impatient variant (resets the
> retransmit timer only on the first partial ack), with
> net.ipv4.tcp_slow_but_steady=1 (default: 0) you can enable the
> Slow-but-Steady variant (resets the retransmit timer every partial
> ack).
> 
> Hoping that this can be useful, I attach the patch.
> 
> Regards,
> Angelo P. Castellani


Read Linus's comments on standards. We make software for users, not for
academic use.
	http://kerneltrap.org/node/5725

If we added this then paranoid users would set it.

The Reno thing seems okay, if the default was the same as the original behavior
but it makes one more test case to try.
