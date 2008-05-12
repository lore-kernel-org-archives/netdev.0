From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 14:32:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-355386201-1210591959=:1888"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58815 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbYELLcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 07:32:42 -0400
In-Reply-To: <4828279C.3010102@damtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-355386201-1210591959=:1888
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 12 May 2008, Damon L. Chesser wrote:

> Ilpo Järvinen wrote:
> > On Thu, 8 May 2008, Ilpo Järvinen wrote:
> >
> > > On Thu, 8 May 2008, Damon L. Chesser wrote:
> > >
> > > > reran the print job with the correct kernel (for control reasons) and
> > > > received
> > > > the same results:  tcp_frto=1 no print.  tcp_frto=0 I can print.  
> > > Attached
> > > > is
> > > > the output of tcpdump
> > > > > uname -r = 2.6.24-1-amd64
> > >
> > > Well, that was a surprise, there must be something else too I didn't yet
> > > notice. I don't think it's that necessary for you to test that patch I
> > > sent
> > > earlier (basically the code paths it would have fixed were already in use
> > > with
> > > tcp_frto=1). And that patch was "obviously correct" anyway though it
> > > wasn't
> > > enough to fix this issue.
> > >
> > > ...I too can probably reproduce this locally with small amount of work
> > > because
> > > the receiver pattern is dead obvious from the logs.
> >
> > Yes indeed, some hping3 tcl acting as a clone of that network printer did it
> > :-). Below is the 2nd patch (both are necessary). Besides them there's still
> > SACKFRTO snd_nxt != frto_highmark problem remaining but it is a lot less
> > severe and rare than this problem was and I'm still trying to find a simple
> > way to fix it w/o adding another u32 to tcp_sock. I may need to think this
> > retrans_stamp usage more around the rest of TCP code too as it seems to be
> > somewhat suspicious here and there.
> >
> on the chance I am being dense:  apply this and the other one with the patch
> command, then compile as normal to taste?

Yes, both are necessary to fully fix it. I'd cut unrelated portions out 
first though to avoid potential problems before running patch. And if you 
have a linux git tree instead, then git-am could be used as "a 
replacement" for patch command (though it would work there too) after 
trimming away things that are before the patch description (before [PATCH] 
line). ...Then a normal compile & boot & test should make you a happy 
person :-).

If you were quick enough (ie., before DaveM does apply the patch upstream) 
and bother to report the result back to netdev without dropping Ccs, 
Dave will add Tested-by: tag with your name in it into the permanent 
commit message which is cool when somebody starts to figure out based on 
those tags who has done testing work for kernel... ;-)

...Thanks for your efforts with this problem.

-- 
 i.
---696208474-355386201-1210591959=:1888--
