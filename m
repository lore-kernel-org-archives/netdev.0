From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Sun, 22 Feb 2009 08:06:50 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902220706130.5291@wrl-59.cs.helsinki.fi>
References: <200902192304.35547.denys@visp.net.lb> <200902201812.47205.denys@visp.net.lb>
 <Pine.LNX.4.64.0902211324460.20284@wrl-59.cs.helsinki.fi>
 <200902220432.47845.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39940 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbZBVGGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 01:06:53 -0500
In-Reply-To: <200902220432.47845.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Feb 2009, Denys Fedoryschenko wrote:

> > Indeed, there's a possiblity that tcp_sacktag_one didn't behave
> > as expected wrt. retrans_out. You shouldn't have had any Leak in or
> > before 2.6.28 (except perhaps in some ancient dev kernels).
>
> Well, not so ancient. I dig more, looks similar:
> 
> Linux corporategw 2.6.18-gentoo-r3 #3 SMP Tue Nov 28 02:05:14 Local time zone 
> must be set--see zic  i686 Intel(R) Xeon(TM) CPU 3.00GHz GenuineIntel 
> GNU/Linux
> TCP: Treason uncloaked! Peer 80.83.30.237:50676/8080 shrinks window 
> 445059938:445066258. Repaired.
> TCP: Treason uncloaked! Peer 80.83.30.237:50676/8080 shrinks window 
> 445059938:445066258. Repaired.
> TCP: Treason uncloaked! Peer 80.83.30.237:50676/8080 shrinks window 
> 445059938:445066258. Repaired.
> TCP: Treason uncloaked! Peer 80.83.25.222:49488/8080 shrinks window 
> 3868565231:3868566407. Repaired.
> TCP: Treason uncloaked! Peer 80.83.25.222:49488/8080 shrinks window 
> 3868565231:3868566407. Repaired.
> TCP: Treason uncloaked! Peer 80.83.25.222:49488/8080 shrinks window 
> 3868565231:3868566407. Repaired.
> 
> NEWNET_PROXY ~ # dmesg
> TCP: Treason uncloaked! Peer 77.222.40.36:80/60350 shrinks window 
> 3300731285:3300731381. Repaired.
> NEWNET_PROXY ~ # uname -a
> Linux NEWNET_PROXY 2.6.19-gentoo-r5 #5 SMP Fri Apr 6 21:13:31 EEST 2007 i686 
> Intel(R) Xeon(TM) CPU 2.40GHz GenuineIntel GNU/Linux
> 
> 
> 
> proxy2 ~ # uname -a
> Linux proxy2 2.6.27-build-0036 #5 SMP Sun Oct 12 14:22:11 Local time zone must 
> be set--see zic  i686 unknown
> 
> [8159479.417657] TCP: Treason uncloaked! Peer 172.16.213.82:3248/8080 shrinks 
> window 3854928708:3854943141. Repaired.
> [8159496.302532] TCP: Treason uncloaked! Peer 172.16.213.82:3248/8080 shrinks 
> window 3854928708:3854943141. Repaired.
> [8218620.535525] UDP: short packet: From 217.151.224.29:21004 34620/1480 to 
> 213.187.247.9:57711
> [8241928.195260] UDP: short packet: From 217.151.224.29:21219 58294/1480 to 
> 213.187.247.9:2490
> [8337257.470320] TCP: Treason uncloaked! Peer 172.16.24.103:49556/8080 shrinks 
> window 4233674068:4233674858. Repaired.
> [8337261.370289] TCP: Treason uncloaked! Peer 172.16.24.103:49556/8080 shrinks 
> window 4233674068:4233674858. Repaired.                                                                                    

No Leaks afaict? Maybe there's some language related confusion (now) 
between us :-). I agree that treasons can happen since they can be 
triggered by the actions of the remote end (though this is not the only 
explanation, in some kernels our local bugs have also caused those 
messages in which we then put blame on the peer :-D). However, the 
authorities recently decided that treasons, literally, must no longer 
happen and put a end to all future treasons ;-) (ie., the message was
slightly modified :-)).

...What I said above is that "Leak" printouts in 2.6.28 and before 
shouldn't be there (or at least I only remember it happening in some 
ancient dev kernels, when it was last time seen). And the patch in 
the previous mail is supposed to deal with the ones that got introduced 
into 2.6.29-rc1.


-- 
 i.
