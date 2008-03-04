From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: TCP IPv4 strange retransmits
Date: Tue, 04 Mar 2008 15:31:31 +0100
Message-ID: <47CD5D43.9020408@nets.rwth-aachen.de>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:58080 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753308AbYCDOaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 09:30:23 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.3.58])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0JX700FR8MYMQ960@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 04 Mar 2008 15:30:22 +0100 (CET)
In-reply-to: <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ilpo J=E4rvinen wrote:
> On Tue, 4 Mar 2008, Arnd Hannemann wrote:
>=20
>> I'm observing some retransmits with kernel 2.6.24.2, which I don't=20
>> understand. For instance in this cutout[1] of a sequence diagram whi=
ch=20
>> was captured[2] on the TCP sender, 4 retransmits are made.
>=20
> They don't correspond to each other?

Hmm, they should.

>=20
>> According to netstat -st output[3][4] all those 4 retransmits were "=
fast=20
>> retransmit".
>> But there are no three DUPACKs which I expected would be needed for =
fast=20
>> retransmit?
>=20
> With FACK it's enough that you have fackets_out > tp->reordering=20
> (=3DdupThresh).

If it is FACK shouldn't it be accounted for LINUX_MIB_TCPFORWARDRETRANS
instead of LINUX_MIB_TCPFASTRETRANS?

>=20
>> Also interesting all retransmits happen _after_ those segments were
>> already acked and sacked, internal queuing or latency issues?
>=20
> I think your viewer is doing something wrong, sender.dump is not givi=
ng=20
> such information (or you draw that from wrong end?). Or it just draws
> DSACK like that?

Viewer is tcptrace and xplot. So nothing special at all.
You see it also in wireshark, if you draw a sequence diagram.
You also see it in wireshark if you sort by capture timestamp. I always=
 thought
that capture timestamp order is correct and not dump order, but maybe I=
'm wrong?

Tcpdump:

12:08:20.667538 IP 192.168.0.7.33824 > 192.168.0.5.50139: . ack 23485 w=
in 22720 <nop,nop,timestamp 969759 972885,nop,nop,sack 2 {24905:26325}{=
27745:29165}>
^^^^^ got acked at .667538

12:08:20.646749 IP 192.168.0.5.50139 > 192.168.0.7.33824: . 22065:23485=
(1420) ack 1 win 2864 <nop,nop,timestamp 972885 969754>
^^^^^ got retransmitted at .646749

>=20
>> It would be great if somebody could shed some light on this,
>> why those segments are retransmitted.
>> Dumps and xplots are available here[5].
>=20
> ...I quickly glanced over it and found no strange behavior in
> the sender.dump.

Best regards,
Arnd

