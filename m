From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 9 Jan 2013 12:03:03 +0000
Message-ID: <1357732983.7989.251.camel@zakaz.uk.xensource.com>
References: <50EC099D.6020407@oracle.com>
	 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
	 <1357652541.7989.179.camel@zakaz.uk.xensource.com>
	 <50EC3DFD.8060206@oracle.com>
	 <1357660834.12649.103.camel@dagon.hellion.org.uk>
	 <50ECC2C4.5060501@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Jason Luan <luanjianhai@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:47271 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757475Ab3AIMDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 07:03:07 -0500
In-Reply-To: <50ECC2C4.5060501@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-09 at 01:07 +0000, Jason Luan wrote:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8809=E6=97=A5 00:00, Ian Campbell =E5=
=86=99=E9=81=93:
> > On Tue, 2013-01-08 at 15:40 +0000, jianhai luan wrote:
> >> On 2013-1-8 21:42, Ian Campbell wrote:
> >>> On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote:
> >>>>>>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com>
> >>>>>>> wrote:
> >>>>>      When Xen Dom0's network circumstance changed, DomU
> >>>>> should be notified in some special condition. For
> >>>>> example the below circumstance:
> >>>>>      ping from Guest A to DomU:
> >>>>>      Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
> >>>>>                  eth1 /
> >>>>>      when eth0 inactive, and eth1 active.
> >>> How is eth0 failing? Are you unplugging it, un-enslaving it or
> >>> taking
> >>> some other sort of administrative action?
> >> In my emulation environment, i unplug it or ifdown the interface,
> > I expect these would behave rather different, since the affect of i=
fdown
> > looks rather different to an unplug from the PoV of the switch.
> >
> > Is the ifdown case something which you are trying to solve or just =
what
> > appeared to be a convenient test case? I'd be less inclined to worr=
y
> > about explict admin actions such as that.
> >
> > Unplugging the cable should cause:
> >
> I do above listed thing to let switch active slave only.
> I think that we should put attention on the thing which bond switch=20
> active slave interface in active-backup mode. In network circumstance=
,=20
> many thing will cause the switch, what do Vif when the event happen?

Sorry, I'm having a bit of trouble parsing the above, but are you askin=
g
what the VIF should do when the active slave in the bond changes withou=
t
the previously active slave actually failing?

The issue is that traffic will continue to arrive on the now inactive
slave, but will be discarded (the expected behaviour for
Active/Passive)?

Is this something which happens in practice? Does the active slave
change even while it remains a viable path?

Ian.
