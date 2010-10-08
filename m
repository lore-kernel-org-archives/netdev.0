From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: Query on usage of Netlink
Date: Fri, 8 Oct 2010 16:01:44 +0530
Message-ID: <20101008103142.GA16460@bnru01.bnr.st.com>
References: <20101008085056.GA13091@bnru01.bnr.st.com>
 <1b4c783a02b46d7da4e308699a41856c@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Srinidhi KASAGAR <srinidhi.kasagar@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:41720 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016Ab0JHKcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 06:32:05 -0400
Content-Disposition: inline
In-Reply-To: <1b4c783a02b46d7da4e308699a41856c@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=E9mi Denis-Courmontt,

On Fri, Oct 08, 2010 at 12:14:44 +0200, R=E9mi Denis-Courmont wrote:
>=20
> On Fri, 8 Oct 2010 14:21:28 +0530, Kumar SANGHVI
> <kumar.sanghvi@stericsson.com> wrote:
> > We have a requirement where-in we want to communicate the status of
> > modem (whether modem is online or offline) from linux driver to
> > user-space components. So that user-space components stop sending d=
ata
> > to linux driver for communicating with modem, in case modem goes
> > offline.
>=20
> Is the modem control state machine in kernel space, as for say, 802.1=
1
> devices?
State machine to keep track of current modem state is in kernel driver.
Kernel driver can know when modem goes offline or when modem is back
online.

> > We have decided to use the netlink mechanism to achieve this. We in=
tend
> > to send an integer value, defined in enum, to user-space indicating=
 the
> > current modem status.
> (...)
> > Or should we define a custom Netlink type in include/linux/netlink.=
h?
>=20
> Did you consider using kobject and uevents (which are internally runn=
ing on
> top of Netlink)?
Yes. However, I believe kobject and uevents require some user-space
daamon like udev which can dispatch the specific uevents to user-space
apps. This user-space daemon then becomes something application
framework specific.
Another option is that user-space app itself open up a netlink socket o=
f type
KOBJECT_UEVENT. But then, user-space will have to filter out
un-necessary uevents out of it.=20

Best regards,
Kumar.
