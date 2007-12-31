From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 18:18:12 +0100
Message-ID: <200712311818.12825.mb@bu3sch.de>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz> <64bb37e0712310817g621d818dyebbf2228063d4d5f@mail.gmail.com> <20071231163803.33acb647@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Torsten Kaiser" <just.for.lkml@googlemail.com>,
	"Adrian Bunk" <bunk@kernel.org>, "Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:38742 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbXLaRS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 12:18:57 -0500
In-Reply-To: <20071231163803.33acb647@the-village.bc.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 December 2007 17:38:03 Alan Cox wrote:
> On Mon, 31 Dec 2007 17:17:19 +0100
> "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> 
> > a) this could be disabled during development if you want this
> > b) this would even only affect development if you add new code that
> > now needs a EXPORT_SYMBOL that was removed on an earlier build. And
> > right now this would also need to trigger a rerun of depmod. And the
> > same trigger could redo this garbage collect.
> > 
> > Or am I missing something obvious?
> 
> Development is not a phase seperate from use or distribution. A lot of
> module testers for distributions will not be compiling their own modules
> but loading in ones to test provided by their vendor - which may of
> course then need different ksyms

As an example, the whole purpose wireless-compat package is
to load latest bleeding edge wireless stuff into a distribution kernel.
So people are not required to recompile their kernels for using
drivers that support their hardware.
And guess what, it is used a _lot_. And lots of bugs are found with it.
It increases our testing community a lot.

So, all this wouldn't work, if kernel symbols could randomly get
nuked by some "garbage collector".

In practice, no distribution would use symbol garbage collection, as the
only benefit from it would be an increased level of bugreports.

-- 
Greetings Michael.
