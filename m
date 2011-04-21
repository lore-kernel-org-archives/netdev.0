From: Dan Williams <dcbw@redhat.com>
Subject: Re: r8169 doesn't report link state correctly.
Date: Thu, 21 Apr 2011 10:55:31 -0500
Message-ID: <1303401332.16512.20.camel@dcbw.foobar.com>
References: <4DA35FEF.1030009@candelatech.com>
	 <20110413174815.GB17579@electric-eye.fr.zoreil.com>
	 <20110420191403.GC18805@electric-eye.fr.zoreil.com>
	 <4DAF569E.1040507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915Ab1DUPxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 11:53:52 -0400
In-Reply-To: <4DAF569E.1040507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 14:56 -0700, Ben Greear wrote:
> On 04/20/2011 12:14 PM, Francois Romieu wrote:
> > Fran=C3=A7ois Romieu<romieu@fr.zoreil.com>  :
> >> On Mon, Apr 11, 2011 at 01:09:19PM -0700, Ben Greear wrote:
> >>> I notice that in kernel 2.6.38-wl, the realtek 8169 NIC doesn't
> >>> report link down when in fact there is no cable connected.  Inste=
ad,
> > [...]
> >> Thanks for the report. I'll try it tomorrow or friday.
> >
> > I have not been able to notice it with a current kernel.
> >
> > I'd welcome the XID of the 8169 NIC (see dmesg) and a short explana=
tion
> > (no cable from boot ? cable removed after ifconfig up ? brand / abi=
lity
> > of the switch / hub ?).
>=20
> Well, as luck would have it, my system will boot today's upstream
> kernel (39-rc4+).  And, I no longer see the problem in that release,
> so it seems it is fixed (or harder to reproduce that I thought).
>=20
> Basically, I was seeing it claim to have link in 'ethtool' output
> when there was no cable connected.  It did go to 10Mbps/half duplex
> link speed when un-plugged.  It showed full 1Gbps link when plugged
> in.
>=20
> I'll let you know if I see this again.

I just had a user run into this bug yesterday on 2.6.38.3 and he
described the exact symptoms in
https://bugzilla.kernel.org/show_bug.cgi?id=3D33782 .  Essentially:

- cable plugged in
- ifconfig eth0 down
- wait a few seconds
- ifconfig eth0 up
- ifconfig eth0 (no LOWER_UP is shown)

If the cable is plugged in, and the device is UP, then we should expect
LOWER_UP indicating the device has a carrier.  But that's not happening=
=2E
If there's any way to isolate a fix and push that fix to stable@ that
would be great...

Dan


