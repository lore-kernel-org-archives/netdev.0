From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Wed, 25 May 2011 09:33:38 +0200
Message-ID: <4DDCB0D2.2050505@gmail.com>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com> <20110524200047.GI21309@gospo.rdu.redhat.com> <4DDC116F.8020602@gmail.com> <20110524203714.GG28521@hmsreliant.think-freely.org> <4DDC1A4E.6080700@gmail.com> <12577.1306271574@death> <20110524231813.GA2350@neilslaptop.think-freely.org> <20007.1306283668@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35350 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019Ab1EYHdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 03:33:42 -0400
Received: by wwa36 with SMTP id 36so8156717wwa.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 00:33:41 -0700 (PDT)
In-Reply-To: <20007.1306283668@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/05/2011 02:34, Jay Vosburgh a =C3=A9crit :

> 	One alternative is to simply permit all option changes while the
> bond is down, then commit then as a set when the bond is brought up (=
or
> fail the open or adjust options if the options are invalid).  More or
> less what you suggest, except that the "commit" is the ifup.
>
> 	Even that is a substantial rework of how things are done now,
> since as you point out, options today take effect more or less in rea=
l
> time.

Agreed.

Setting an option while the master is down should only syntax-check the=
 option value and store the=20
value for later use (at the time we bring the bond up). Setting an opti=
on while the master is up=20
should take effect in realtime if possible/appropriate or store it and =
issue a warning saying one=20
need to down+up the bond to commit the change.

>> This also begs the question, is it or is it not safe to enslave devi=
ces while
>> the bond is down?  Clearly from the bug report its unsafe, and I don=
't know what
>> other (if any) conditions exist that cause problems when doing this =
(be that a
>> deadlock, panic or simply undefined or unexpected behavior).  If its=
 really
>> unsafe, then issuing a warning seems incorrect, we shouldn't allow u=
ser space to
>> cause things like this, and as such, we should return an error.  If =
it is safe
>> (generally) and this is an isolated bug, then we should probably rem=
ove the
>> warning.  But to just issue a vague 'This might do bad things' warni=
ng seems
>> wrong in either case.
>
> 	Agreed.  I think it (conceptually) should be safe to add or
> remove slaves when the bond is down, and bonding shouldn't complain
> about it.

Are there any reasons not to consider enslavement as a normal option wi=
th the same processing as=20
other options (only do real enslavement at the time we bring the master=
 up)?

	Nicolas.
