From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP IPv4 strange retransmits
Date: Tue, 4 Mar 2008 15:36:42 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
References: <47CD4808.1050202@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48044 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbYCDNgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 08:36:48 -0500
In-Reply-To: <47CD4808.1050202@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Mar 2008, Arnd Hannemann wrote:

> I'm observing some retransmits with kernel 2.6.24.2, which I don't 
> understand. For instance in this cutout[1] of a sequence diagram which 
> was captured[2] on the TCP sender, 4 retransmits are made.

They don't correspond to each other?

> According to netstat -st output[3][4] all those 4 retransmits were "fast 
> retransmit".
> But there are no three DUPACKs which I expected would be needed for fast 
> retransmit?

With FACK it's enough that you have fackets_out > tp->reordering 
(=dupThresh).

> Also interesting all retransmits happen _after_ those segments were
> already acked and sacked, internal queuing or latency issues?

I think your viewer is doing something wrong, sender.dump is not giving 
such information (or you draw that from wrong end?). Or it just draws
DSACK like that?

> It would be great if somebody could shed some light on this,
> why those segments are retransmitted.
> Dumps and xplots are available here[5].

...I quickly glanced over it and found no strange behavior in
the sender.dump.

-- 
 i.
