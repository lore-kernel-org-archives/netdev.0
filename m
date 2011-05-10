From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
 bond - regression
Date: Tue, 10 May 2011 10:54:32 +0200
Message-ID: <1305017672.2614.9.camel@edumazet-laptop>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Frank Blaschka <Frank.Blaschka@de.ibm.com>
To: Einar EL Lueck <ELELUECK@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61373 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab1EJIyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 04:54:37 -0400
Received: by wya21 with SMTP id 21so4491248wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 01:54:35 -0700 (PDT)
In-Reply-To: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 10:17 +0200, Einar EL Lueck a =C3=A9crit :
> Hi Dave,
>=20
> Einar EL Lueck/Germany/IBM wrote on 04/29/2011 04:45:45 PM:
>=20
> > From:
> >
> > Einar EL Lueck/Germany/IBM
> >
> > To:
> >
> > opurdila@ixiacom.com, netdev@vger.kernel.org, linux-
> > s390@vger.kernel.org, davem@davemloft.net
> >
> > Cc:
> >
> > Frank Blaschka/Germany/IBM@IBMDE
> >
> > Date:
> >
> > 04/29/2011 04:45 PM
> >
> > Subject:
> >
> > Re: oops during unregister_netdevice interface enslaved to bond -
> regression
> >
> > Hi Octavian,
> >
> > On 04/15/2011 10:53 AM, Frank Blaschka wrote:
> > > Hi Octavian,
> > >
> > > your commit 443457242beb6716b43db4d62fe148eab5515505 introduced
> > this regression.
> > > I have reviewed the net device unregister code but did not
> > understand it very well.
> > > I have seen the problem only in combination with bonding. Can you
> > give me some help
> > > how to go on with this problem. I can reproduced it very easy on
> asingle CPU
> > > machine.
> > >
> >
> > In this case rollback_registered_many iterates over the list of dev=
s
> > that initially has just one device in it. In a loop it calls
> > call_netdevice_notifiers(NETDEV_UNREGISTER, dev) which triggers the
> > bonding driver to call dev_close_many for the same device. That cal=
l
> > to dev_close_many leads to the addition of the same device to the
> > list over which rollback_registered_many is iterating. Consequently=
,
> > netdev_unregister_kobject(dev) is called twice for the same device.
> > Frank captured the result in his mail.
> >
>=20
> Calls to the *_many functions introduced by Octavian may never interl=
eave
> because
> the traversed lists modify each other. This was the root cause for th=
e
> symptom that Frank discovered. Octavian is not a valid mail recipient
> anymore and did not react from any new mail address. I suggest to rev=
ert
> the commit.
>=20

Hello Einar

I am currently working on this stuff [adding even more batching and
probably bugs as well ], so instead of revert I'll try to find a way to
fix this.

If you already have a script to reproduce the bug on virtual devices on
x86 (not on s390 machines I dont have ;) ), I'll appreciate having a
copy of it.

Thanks for the reminder.

