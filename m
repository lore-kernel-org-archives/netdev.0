From: "George B." <georgeb@gmail.com>
Subject: Re: Network multiqueue question
Date: Thu, 15 Apr 2010 20:54:32 -0700
Message-ID: <i2wb65cae941004152054nb301536ep1ba8a9d06cccb781@mail.gmail.com>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
	 <1271353637.16881.2846.camel@edumazet-laptop>
	 <21433.1271354986@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:45988 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757702Ab0DPDyc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 23:54:32 -0400
Received: by pzk42 with SMTP id 42so1680652pzk.4
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 20:54:32 -0700 (PDT)
In-Reply-To: <21433.1271354986@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 11:09 AM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:


> =A0 =A0 =A0 =A0The question I have about it (and the above patch), is=
: what
> does multi-queue "awareness" really mean for a bonding device? =A0How=
 does
> allocating a bunch of TX queues help, given that the determination of
> the transmitting device hasn't necessarily been made?

Good point.

> =A0 =A0 =A0 =A0I haven't had the chance to acquire some multi-queue n=
etwork
> cards and check things out with bonding, so I'm not really sure how i=
t
> should work. =A0Should the bond look, from a multi-queue perspective,=
 like
> the largest slave, or should it look like the sum of the slaves? =A0S=
ome
> of this is may be mode-specific, as well.

I would say that having the number of bands be either the number of
cores or 4, whichever is the smaller would be a good start.  That is
probably fine for GigE.  Of the network cards we have that support
multiqueue, they are either 4 or 8 bands.  In an optimal world, you
would have the number of bands that you have available at the physical
ethernet level but changing those on the fly in case of a change in
available interfaces might be more trouble than it is worth.

=46our or eight would seem to be a good number to start with as I don't
think I have seen an ethernet card with less than 4.  If you have
fewer than 4 CPUs there probably isn't much utility in having more
bands than processors, or maybe that utility rapidly diminishes as the
number of bands increases beyond the number of CPUs.  At that point
you have probably just spent a lot of work building a bigger buffer.

I would be happy with 4 bands.  I guess it just depends on where you
want the bottleneck.  If you have 8 bands on the bond driver (another
reasonable alternative) and only 4 bands available for output, you
have just moved the contention down a layer to between the bond and
the ethernet driver.  But I am a fan of moving the point of contention
as far away from the application interface as possible.  If I have one
big lock around the bond driver and have 6 things waiting to talk to
the network, those are six things that can't be doing anything else.
I would rather have the application handle its network task and get
back to other things.  Now if you have 8 bands of bond and only 4
bands of ethernet, or even one band of ethernet, oh well.  Maybe have
1 to 8 bands configurable by an option to the driver that could be set
explicitly and defaults to, say, 4?

Thanks for taking the time to answer.

George
