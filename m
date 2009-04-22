From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 22 Apr 2009 17:02:06 +0300
Message-ID: <1240408926.6554.57.camel@blade.ines.ro>
References: <1239964844.21569.57.camel@blade.ines.ro>
	 <49E905A2.7040402@gmail.com> <200904180321.50281.denys@visp.net.lb>
	 <20090418075637.GA2738@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:34901 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755169AbZDVOCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 10:02:13 -0400
In-Reply-To: <20090418075637.GA2738@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-04-18 at 09:56 +0200, Jarek Poplawski wrote:
> Right, if you're using high resolution; there is a bug in tc, found by
> Denys, which causes wrong (too low) defaults for burst/cburst.
> 
> > Also worth to try HFSC.
> 
> Yes, it seems to be especially interesting for 64 bit boxes.

Hi Jarek,

Thanks for the hints! As far as I understand, HFSC is also implemented
as a queue discipline (like HTB), so I guess it suffers from the same
design limitations (doesn't span across multiple CPUs). Is this
assumption correct?

As for htb_hysteresis I actually haven't tried it. Although it is
definitely worth a try (especially if the average traffic grows), I
don't think it can compensate multithreading / parallel execution. At
least half of a packet processing time is consumed by classification
(although I am using hashes). I guess htb_hysteresis only affects the
actual shaping (which takes place after the packet is classified).

Thanks,

Radu Rendec


