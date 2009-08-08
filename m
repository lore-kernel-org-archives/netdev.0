From: jamal <hadi@cyberus.ca>
Subject: Re: some bug in iproute2
Date: Sat, 08 Aug 2009 08:49:41 -0400
Message-ID: <1249735781.7101.53.camel@dogo.mojatatu.com>
References: <20090807101250.GA14064@ff.dom.local>
	 <1249655285.7101.6.camel@dogo.mojatatu.com> <20090807202725.784dab6b@azure>
	 <1249734651.7101.38.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Sergey Popov <popov_sergey@ukr.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:4096 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934107AbZHHMvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 08:51:41 -0400
Received: by qw-out-2122.google.com with SMTP id 8so840878qwh.37
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2009 05:51:41 -0700 (PDT)
In-Reply-To: <1249734651.7101.38.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergey,

Hope you dont mind if i cc some other people so we can
resolve this issue because i am looking at the git logs
and seeing tons of activities which affect what you are
trying to do.

On Sat, 2009-08-08 at 08:30 -0400, jamal wrote:
> Hi,
>=20
> On Fri, 2009-08-07 at 20:27 +0300, Sergey Popov wrote:
> > =D0=92 Fri, 07 Aug 2009 10:28:05 -0400


> > Now i want to police the incoming traffic and drop all the packets
> > that exceeds the 1000 kbit and redirect packets
> > to ifb, but next line doesn't work as expected [by me]:
> >=20
>=20
> What distro are you running?
>=20
> > # tc f add dev $INETIF parent ffff: proto ip prio 1 u32 match u32 0=
 0 \
> > action police rate 1000kbit burst 1k drop \
> > action mirred egress redirect dev $IFBIF
> >=20
> > Illegal "action"
> > bad action parsing
> > parse_action: bad value (12:police)!
> > Illegal "action"
>=20
> Let me try simple version:
> dogo:~# tc q add dev lo ingress
> dogo:~# tc f add dev lo parent ffff: proto ip prio 1 u32 match u32 0 =
0
> action police rate 1000kbit burst 1k drop action mirred egress redire=
ct
> dev eth0
> Illegal "action"
> bad action parsing
> parse_action: bad value (12:police)!
> Illegal "action"
> dogo:~#=20
>=20
> Ok, this seems to be a bug with policer...
> Although your syntax above seems wrong since you didnt specify flowid=
=2E
> You must specify flowid always or strange things will happen even if
> the syntax is accepted.

Your usage and syntax is perfectly legal and very useful.
The problem is in the old policer syntax the keyword "action" had some
speacial meaning. Some old scripts used it and broke if new syntax was
used.
The only clean option i see forward (which doesnt break any legacy stuf=
f
or play acrobatics) is to introduce new action "npolice". Patrick,
thoughts?

cheers,
jamal


