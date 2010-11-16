From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iproute2: use automake
Date: Tue, 16 Nov 2010 21:12:35 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011162111570.24880@obet.zrqbmnf.qr>
References: <20101115.175928.104078108.davem@davemloft.net> <alpine.LNX.2.01.1011161108330.25859@obet.zrqbmnf.qr> <20101116075851.0de8d177@nehalam> <20101116.094132.59704380.davem@davemloft.net> <alpine.LNX.2.01.1011162017320.24880@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, stephen.hemminger@vyatta.com,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:37150 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759402Ab0KPUMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 15:12:36 -0500
In-Reply-To: <alpine.LNX.2.01.1011162017320.24880@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 2010-11-16 18:41, David Miller wrote:
>
>> Until you make a convincing case that the existing infrastructure
>> is a problem, choosing an alternative solution is bogus.
>
>I can't count the amount of times I've seen major source trees
>invest tons of engineering into things to decrease the pain of
>using things like automake and libtool.

The pro argument for a build system is not that Linux-only projects
receive unneeded portability work, but that the work involved with
maintaining all the commands in Makefiles, which tend to be a source
of update anomalies, gets reduced.

>X11 even has a script that basically turns libtool into one big
>fat NOP, because on Linux everything libtool tries to figure out
>is completely superfluous.

(I was not trying to make a case for Libtool specifically.)

And yet they do use a build system (which happens to be Automake, but
that's not my point). Was their time spent just to produce,
"unnecessary non-sense", as you call it? I can imagine they will
disagree with you.

>Don't crap up the tree with unnecessary non-sense just for some
>theoretical gain.  Things work just fine right now.

They do not.

* running make in subdirs is broken
* iproute2/arpd compilation fails if db_185.h, atm.h is not present
  and
* people could not quite opt out building arpd when they are
  fine with not having it
* the DESTDIR variable was completely abused
* data files were shoven into /usr/lib where they don't even belong
  (that is, if you care about FHS even a tiny bit)
* NO_SHARED_LIBS=y is broken
* -lresolv was added unconditionally when it's not even needed
* CFLAGS was overriden, which means a user running make CFLAGS="-g"
  will kill the all-important -Wall and -I../include
* Out-of-tree building, anyone?

But what do I say; if it works _for you_, I must be wrong by
definition.
