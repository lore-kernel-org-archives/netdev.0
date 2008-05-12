From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 22:12:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com>
 <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com>
 <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi> <482849C9.30905@damtek.com>
 <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi> <48288EFE.4020708@damtek.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary=------------030103060709010400020208
Cc: Netdev <netdev@vger.kernel.org>
To: "Damon L. Chesser" <damon@damtek.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45076 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097AbYELTMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 15:12:50 -0400
In-Reply-To: <48288EFE.4020708@damtek.com>
Content-ID: <Pine.LNX.4.64.0805122148560.14152@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------030103060709010400020208
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805122143082.14152@wrl-59.cs.helsinki.fi>

On Mon, 12 May 2008, Damon L. Chesser wrote:

> Ilpo Järvinen wrote:
> > On Mon, 12 May 2008, Damon L. Chesser wrote:
> >
> > > I applied the patches in order, no errors on that.  I compiled a stock
> > > 2.4.24-1 kernel with the patches, I saw no errors there.
> > >
> > > booted into new kernel, printed with tcp_frto=0.  set tcp_frto =2,
> > > restarted
> > > the network (is this required, or is this a dynamic setting?), printed
> > > from OO
> > > document.  No joy.  tcpdump log attached (almost 15 min. worth of data)
> > >
> > > If you want, I can re-compile and double check for any compilation errors,
> > > however, if there were any, it was not sever enough to stop the
> > > compilation.
> >
> > On the bright side, the FRTO problem that was occuring previously is now
> > fixed but there seems to be very few ways to communicate with that device
> > sanely because it assumes in-order arrival and keeps discarding, as it
> > seems, _all_ other segments... If you could try with this additional
> > work-around attached (keep the fixes there as well). Turn
> > tcp_frto_inorder_workaround sysctl to 1 before testing with FRTO.
> >
> > ...Can you please send a dump about working case too, this seems rather
> > nasty device to work with (tcp_frto = 0 is enough to attain it, no need to
> > have another kernel booted for that) and I'm interested to see what are the
> > loss rates without FRTO...
> >
> >
> New patch added in with the first two, tcp_frto_inorder_workaround =1 test
> printed 5 pages:  This worked.  Attached is the output of tcpdump.  Need
> anything else?

Thanks a lot for the testing & all. The picture is clear enough already, 
so no additional help needed (I haven't yet looked the non-frto dump but
I doubt anything earth-shattering turns out, it's mostly interesting for 
finding out how efficiently such network printer TCP can consume segments 
it's receiving once FRTO related "fuzzy" ordering effects are removed, 
for comparison purposes, mostly interesting and that's for hc tcp guy like 
me :-)).


Then one question for DaveM:

What I'm not fully sure of, is do we want this workaround to be a sysctl 
or unconditionally enabled which causes potentially up to two unnecessary 
retransmissions? With SACK one or both of them will get SACKed before they 
get retransmitted (both cases have common scenarios). (I made that 
workaround patch for 2.6.24.1, so YMMV if you just plainly try to apply it 
to net-2.6).

-- 
 i.
--------------030103060709010400020208--
