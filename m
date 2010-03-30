From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: UDP path MTU discovery
Date: Tue, 30 Mar 2010 08:58:32 -0700
Message-ID: <E1829B60731D1740BB7A0626B4FAF0A649E05EABD5@XCH-NW-01V.nw.nos.boeing.com>
References: <1269561751.2891.8.camel@ilion>
 	<877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com>
 	<20100329201431.GH20695@one.firstfloor.org>
 	<20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com>
 	<1269898152.1958.86.camel@edumazet-laptop>
 	<E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
 	<20100330052044.GJ20695@one.firstfloor.org>
 	<20100330061627.GA22436@laped.iglesias.mooo.com>
 <20100330061952.GO20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:44526 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790Ab0C3Qcc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 12:32:32 -0400
In-Reply-To: <20100330061952.GO20695@one.firstfloor.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Andi Kleen [mailto:andi@firstfloor.org]
> Sent: Monday, March 29, 2010 11:20 PM
> To: Edgar E. Iglesias
> Cc: Andi Kleen; Templin, Fred L; Eric Dumazet; Rick Jones; Glen Turner; netdev@vger.kernel.org
> Subject: Re: UDP path MTU discovery
> 
> > If you don't want to hassle with all of that, the app can stick to
> > 1280 (or I guess for the extreme/lazy cases turn on fragmentation)..
> 
> See the early mails in this thread. This is about apps who can't
> limit themselves to 1280, but still don't want full blown PMTU.
> [They probably should, but it can be a lot of work]

Right. Some apps may need to send isolated packets that
are larger than the path MTU without invoking path MTU
discovery.
 
> The MTU would allow to force fragmentation on the sending host
> as a workaround similar to IPv4.

Right again. Unlike IPv4, however, IPv6 does not allow
in-the-network fragmentation. So when in doubt, apps
that need to send isolated packets that may violate the
path MTU should really perform host-based fragmentation
with a maximum fragment size of 1280. Isn't there a
socket option "IPV6_USE_MIN_MTU" that apps can use to
force fragmentation on large packets (RFC3542)?

Caveat - the app may have no way of knowing whether
the destination is capable of reassembling fragmented
packets larger than 1500...

Fred
fred.l.templin@boeing.com

> -Andi
> --
> ak@linux.intel.com -- Speaking for myself only.
