From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/3] ser_gigaset: fix deallocation of platform device
 structure
Date: Thu, 10 Dec 2015 12:20:22 +0100
Message-ID: <1449746422.16068.18.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
	 <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
	 <1449616321.2384.36.camel@tiscali.nl> <56680C25.1050704@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud2.xs4all.net ([194.109.24.25]:47339 "EHLO
	lb2-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbbLJLU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 06:20:26 -0500
In-Reply-To: <56680C25.1050704@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On wo, 2015-12-09 at 12:10 +0100, Tilman Schmidt wrote:
> Am 09.12.2015 um 00:12 schrieb Paul Bolle:

> > So what does setting
> > cs->hw.ser->dev.dev.driver_data to NULL just before freeing it buy
> > us?
> 
> We're freeing cs->hw.ser, not cs->hw.ser->dev.
> Clearing the reference to cs from the device structure before freeing 
> cs guards against possible use-after-free.
> 
> > > +	kfree(cs->hw.ser);
> > > +	cs->hw.ser = NULL;
> > 
> > I might be missing something, but what does setting this to NULL buy 
> > us here?
> 
> Just defensive programming. Guarding against possible use-after-free 
> or double-free.

I'm inclined to think this is not the best way to guard against such
nasty bugs. But then again, I'm only a few months into my shift of
looking after the gigaset drivers and haven't had to track down such
bugs yet. But I'd be surprised if many other drivers do it that way and
think this is a job for (tree wide) debugging tools. But, whatever the
merits of our views, we can defer this discussion to some future date.
See below.

> I'm a big fan of one change per patch. If we also want to modify the
> moved code then that should be done in a separate patch. It makes
> bisecting so much easier. Same reason why I separated out patch 3/3.


Fair enough.


Paul Bolle
