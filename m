From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/7] Allow to monitor multicast cache event via rtnetlink
Date: Fri, 7 Dec 2012 10:38:37 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70E4@saturn3.aculab.com>
References: <50BE56D3.2030704@6wind.com> <50BF29DA.7020903@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com> <20121205.125453.1457654258131828976.davem@davemloft.net> <50C05AC2.1050504@6wind.com> <20121206174905.GC16122@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>,
	"Nicolas Dichtel" <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59982 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755962Ab2LGKnm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 05:43:42 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29970-06 for <netdev@vger.kernel.org>;
 Fri,  7 Dec 2012 10:43:37 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121206174905.GC16122@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 12/06/12 at 09:43am, Nicolas Dichtel wrote:
> > Le 05/12/2012 18:54, David Miller a =E9crit :
> > >From: "David Laight" <David.Laight@ACULAB.COM>
> > >Date: Wed, 5 Dec 2012 11:41:33 -0000
> > >
> > >>Probably worth commenting that the 64bit items might only be 32bi=
t aligned.
> > >>Just to stop anyone trying to read/write them with pointer casts.
> > >
> > >Rather, let's not create this situation at all.
> > >
> > >It's totally inappropriate to have special code to handle every si=
ngle
> > >time we want to put 64-bit values into netlink messages.
> > >
> > >We need a real solution to this issue.
> > >
> > The easiest way is to update *_ALIGNTO values (maybe we can keep
> > NLMSG_ALIGNTO to 4). But I think that many userland apps have these
> > values hardcoded and, the most important thing, this may increase
> > size of many netlink messages. Hence we need probably to find
> > something better.
>=20
> We can't do this, as you say, ALIGNTO is compiled into all the
> binaries.
>=20
> A simple backwards compatible workaround would be to include an
> unknown, empty padding attribute if needed. That would be 4 bytes
> in size and could be used to include padding as needed.

What are you going to align the data with respect to?
I doubt you can assume that the start of the netlink
message itself is 8 byte aligned - so any attempt
to 8 byte align an item is probably doomed to failure.

	David
