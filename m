From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Sat, 28 Mar 2009 01:05:09 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55373 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbZC0XFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 19:05:13 -0400
In-Reply-To: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Mar 2009, Markus Trippelsdorf wrote:

> I'm running the latest git kernel (2.6.29-03321-gbe0ea69) and I've got
> this warning twice in the last few hours.:

What did you run previously?

> Mar 27 21:37:00 [kernel] ------------[ cut here ]------------
> Mar 27 21:37:00 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()

This one may or may not be a new one... Starting from the point when the 
warning was added it has been seen and some of those miscounts got tracked 
down but there is still something remaining (and that has been the state 
for couple of version already). It seems to require some particularly hard 
to reproduce network behavior people usually hit once in a lifetime. 
However, those miscount alone should not cause crashes, stalled TCP at 
worst but even that is quite unlikely to happen if fackets_out was not 
counted right.

> The machine hangs afterwards.

Is it really related to the warning for sure? I find it hard to 
believe...

We even fixed that miscount for you when the warning was printed out (and 
the miscount alone wouldn't be able to cause crash anyway). Obviously 
there could something that got broken but reading through all post 2.6.29 
tcp material doesn't reveal anything particularly suspicious or even 
tricky... Only one thing that is remotely related to the warning that gets 
printed out is d3d2ae454501a4dec360995649e1b002a2ad90c5 but even that has 
very strong foundation as it does not have any potential to introduce 
stale references, rest of the effects would be just stalled tcp connection 
at worst.

Please add some debugging things, at least lockdep (CONFIG_PROVE_LOCKING) 
and soft lockup detector (CONFIG_DETECT_SOFTLOCKUP) to find out if we can 
get some info about the actual place of hang, some other debug things 
might also end up being useful.

Thanks for the report.

-- 
 i.
