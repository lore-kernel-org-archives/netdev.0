From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
Date: Tue, 25 Mar 2008 23:24:55 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803250942450.14461@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
 <pan.2008.03.24.20.36.07@telenet.be> <20080324.144107.235200795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-488788762-1206431468=:14461"
Cc: fhimpe@telenet.be, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37775 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYCYVY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 17:24:58 -0400
In-Reply-To: <20080324.144107.235200795.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0803252310560.6132@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-488788762-1206431468=:14461
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803252302351.6132@kivilampi-30.cs.helsinki.fi>

On Mon, 24 Mar 2008, David Miller wrote:

> From: Frederik Himpe <fhimpe@telenet.be>
> Date: Mon, 24 Mar 2008 20:36:08 +0000 (UTC)
> 
> > On Mon, 03 Mar 2008 15:53:12 +0200, Ilpo Järvinen
> > wrote:
> > 
> > > [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
> > > 
> > > It makes fackets_out to grow too slowly compared with the real write
> > > queue.
> > > 
> > > This shouldn't cause those BUG_TRAP(packets <= tp->packets_out) to
> > > trigger but how knows how such inconsistent fackets_out affects here and
> > > there around TCP when everything is nowadays assuming accurate
> > > fackets_out. So lets see if this silences them all.
> > > 
> > > Reported by Guillaume Chazarain <guichaz@gmail.com>.
> > 
> > Will this patch be applied to 2.6.24 stable? I think I have been hit by 
> > the same problem recently:
> 
> I'll push it to the -stable folks for their next release
> since people are actively hitting it.

Please don't, it's not the right fix, it fixed a bug that was
introduced post 2.6.24 by this commit:

commit 68f8353b480e5f2e136c38a511abdbb88eaa8ce2
Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Date:   Thu Nov 15 19:50:37 2007 -0800

    [TCP]: Rewrite SACK block processing & sack_recv_cache use


There's something else wrong with the 2.6.24.y. I already knew that and 
was therefore planning next to run extensive set of tests on 2.6.24ish 
kernel with some torrent mixed with some netem stimuli but haven't yet had 
time for that as I had to find and resolve an hw incompatibility issues 
between ddr2s and mobo before being a week away. I'll post an 2.6.24.y 
adapted TCP debug patch once I get that done for my tests (in case 
somebody else is interested in running with it besides me).

Btw, it would have been polite to cc me as well (I suppose you just didn't 
notice that somebody dropped me in between :-)), not a big prob though as 
I found it out early anyway because I'm trying to catch up what has been 
reported against TCP during my week away.


-- 
 i.
---696243703-488788762-1206431468=:14461--
