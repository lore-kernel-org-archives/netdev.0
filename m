From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 19:37:43 +0100
Message-ID: <64bb37e0712311037w42bae43ayb3c10b2e0310586d@mail.gmail.com>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
	 <64bb37e0712310817g621d818dyebbf2228063d4d5f@mail.gmail.com>
	 <20071231163803.33acb647@the-village.bc.nu>
	 <200712311818.12825.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Adrian Bunk" <bunk@kernel.org>, "Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:29207 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbXLaShp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 13:37:45 -0500
Received: by py-out-1112.google.com with SMTP id u52so9137251pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 10:37:44 -0800 (PST)
In-Reply-To: <200712311818.12825.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 31, 2007 6:18 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Monday 31 December 2007 17:38:03 Alan Cox wrote:
> > On Mon, 31 Dec 2007 17:17:19 +0100
> > "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> >
> > > a) this could be disabled during development if you want this
> > > b) this would even only affect development if you add new code that
> > > now needs a EXPORT_SYMBOL that was removed on an earlier build. And
> > > right now this would also need to trigger a rerun of depmod. And the
> > > same trigger could redo this garbage collect.
> > >
> > > Or am I missing something obvious?
> >
> > Development is not a phase seperate from use or distribution. A lot of
> > module testers for distributions will not be compiling their own modules
> > but loading in ones to test provided by their vendor - which may of
> > course then need different ksyms

I understand that point.
I just always assumed that kernel tests meant 'please test this patch'
and doing the compile yourself.

But I'm not convinced be the following:
> As an example, the whole purpose wireless-compat package is
> to load latest bleeding edge wireless stuff into a distribution kernel.
> So people are not required to recompile their kernels for using
> drivers that support their hardware.
> And guess what, it is used a _lot_. And lots of bugs are found with it.
> It increases our testing community a lot.

This looks more like a "regular" out-of-tree module for the purpose of
the suggested symbol garbage collector.
And for that case I already a 'don't use it then'-note.

The base problem is that there already are many options to break
external modules. (CONFIG_MODULES=n ;) )
Or in the case of this wireless module: CONFIG_CRYPTO_ARC4=n
(Without 'arc4' ieee80211_wep_init() will fail, that will fail
ieee80211_register_hw() and so no mac80211 driver could be loaded)

> So, all this wouldn't work, if kernel symbols could randomly get
> nuked by some "garbage collector".
>
> In practice, no distribution would use symbol garbage collection, as the
> only benefit from it would be an increased level of bugreports.

The question I can't answer in this context is: Do distributions want
to support external modules?
Only if yes, your argument is valid. But then they could just disable
this feature and prevent this kind of bugreports.

Torsten
