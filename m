From: Matt Mackall <mpm@selenic.com>
Subject: Re: netconsole as normal console for userspace messages?
Date: Tue, 01 Sep 2009 12:34:34 -0500
Message-ID: <1251826474.3960.597.camel@calx>
References: <20090901101612.GB5222@ff.dom.local>
	 <1251818111.3960.425.camel@calx>
	 <200909011800.40243.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:49446 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbZIARfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 13:35:00 -0400
In-Reply-To: <200909011800.40243.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-01 at 18:00 +0200, Arkadiusz Miskiewicz wrote:
> On Tuesday 01 of September 2009, Matt Mackall wrote:
> > On Tue, 2009-09-01 at 10:16 +0000, Jarek Poplawski wrote:
> > > On 30-08-2009 02:12, Arkadiusz Miskiewicz wrote:
> > > > Hi,
> > >
> > > Hi,
> > >
> > > > Can netconsole be somehow used to see userspace messages, too?
> > > > Something similar to console=ttySX... just =netconsole.
> > >
> > > AFAIK it can't, but AFAICR some time ago the netconsole maintainer
> > > gave some hope to some Debian guy with a similar question.
> >
> > It is, as they say, just a simple matter of programming to get a full
> > bidirectional console out of it. As cool as that would be, I just
> > haven't had time for it.
> 
> Unidirectional console would be enough for me but it seems that netconsole 
> isn't capable even for that (userspace messages).

Yes. What's needed is to add a low-level tty interface and register it
with the tty core. Most of that is attaching the tty_ops->write() method
to netpoll's send_msg in the obvious way. Just about all the other
methods are optional or trivial. 

Once you've got unidirectional working, bidirectional is approximately
one line of additional code to attach the read side: call
tty_insert_flip_string(my_tty, buf, len) in netpoll's receive function.

-- 
http://selenic.com : development and support for Mercurial and Linux


