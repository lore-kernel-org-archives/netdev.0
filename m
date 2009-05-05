From: Willy Tarreau <w@1wt.eu>
Subject: Re: Wrong network usage reported by /proc
Date: Tue, 5 May 2009 07:50:32 +0200
Message-ID: <20090505055032.GA29582@1wt.eu>
References: <20090504171408.3e13822c@python3.es.egwn.lan> <49FF2BB2.4030700@cosmosbay.com> <20090504211151.74622f29@python3.es.egwn.lan> <20090505050435.GK570@1wt.eu> <49FFCD08.7050600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4274 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbZEEFuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 01:50:40 -0400
Content-Disposition: inline
In-Reply-To: <49FFCD08.7050600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 05, 2009 at 07:22:16AM +0200, Eric Dumazet wrote:
> Willy Tarreau a =E9crit :
> > On Mon, May 04, 2009 at 09:11:51PM +0200, Matthias Saou wrote:
> >> Eric Dumazet wrote :
> >>
> >>> Matthias Saou a =E9crit :
> >>>> Hi,
> >>>>
> >>>> I'm posting here as a last resort. I've got lots of heavily used=
 RHEL5
> >>>> servers (2.6.18 based) that are reporting all sorts of impossibl=
e
> >>>> network usage values through /proc, leading to unrealistic snmp/=
cacti
> >>>> graphs where the outgoing bandwidth used it higher than the phys=
ical
> >>>> interface's maximum speed.
> >>>>
> >>>> For some details and a test script which compares values from /p=
roc
> >>>> with values from tcpdump :
> >>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
> >>>>
> >>>> The values collected using tcpdump always seem realistic and mat=
ch the
> >>>> values seen on the remote network equipments. So my obvious conc=
lusion
> >>>> (but possibly wrong given my limited knowledge) is that somethin=
g is
> >>>> wrong in the kernel, since it's the one exposing the /proc inter=
face.
> >>>>
> >>>> I've reproduced what seems to be the same problem on recent kern=
els,
> >>>> including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right n=
ow. The
> >>>> simple python script available here allows to see it quite easil=
y :
> >>>> https://www.redhat.com/archives/rhelv5-list/2009-February/msg001=
66.html
> >>>>
> >>>>  * I run the script on my Workstation, I have an FTP server enab=
led
> >>>>  * I download a DVD ISO from a remote workstation : The values m=
atch
> >>>>  * I start ping floods from remote workstations : The values rep=
orted
> >>>>    by /proc are much higher than the ones reported by tcpdump. I=
 used
> >>>>    "ping -s 500 -f myworkstation" from two remote workstations
> >>>>
> >>>> If there's anything flawed in my debugging, I'd love to have som=
eone
> >>>> point it out to me. TIA to anyone willing to have a look.
> >>>>
> >>>> Matthias
> >>>>
> >>> I could not reproduce this here... what kind of NIC are you using=
 on
> >>> affected systems ? Some ethernet drivers report stats from card i=
tself,
> >>> and I remember seeing some strange stats on some hardware, but I =
cannot
> >>> remember which one it was (we were reading NULL values instead of
> >>> real ones, once in a while, maybe it was a firmware issue...)
> >> My workstation has a Broadcom BCM5752 (tg3 module). The servers wh=
ich
> >> are most affected have Intel 82571EB (e1000e). But the issue is th=
at
> >> with /proc, the values are a lot _higher_ than with tcpdump, and t=
he
> >> tcpdump values seem to be the correct ones.
> >=20
> > the e1000 chip reports stats every 2 seconds. So you have to collec=
t
> > stats every 2 seconds otherwise you get "camel-looking" stats.
> >=20
>=20
> I looked at e1000e driver, and apparently tx_packets & tx_bytes are c=
omputed
> by the TX completion routine, not by the chip.

Ah I thought that was the chip which returned those stats every 2 secon=
ds,
otherwise I don't see the reason to delay their reporting. Wait, I'm sp=
eaking
about e1000, never tried e1000e. Maybe there have been changes there. A=
nyway,
Matthias talked about RHEL5's 2.6.18 in which I don't think there was e=
1000e.

Anyway we did not get any concrete data for now, so it's hard to tell (=
I
haven't copy-pasted the links above in my browser yet).

Regards,
Willy

