From: "H. Willstrand" <h.willstrand@gmail.com>
Subject: Re: TCP IPv4 strange retransmits
Date: Tue, 4 Mar 2008 22:04:09 +0100
Message-ID: <175f5a0f0803041304k3bb75170v7bee8e7448389a81@mail.gmail.com>
References: <47CD4808.1050202@nets.rwth-aachen.de>
	 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
	 <47CD5D43.9020408@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: "Arnd Hannemann" <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:60085 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbYCDVEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:04:12 -0500
Received: by wf-out-1314.google.com with SMTP id 28so1313697wff.4
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 13:04:10 -0800 (PST)
In-Reply-To: <47CD5D43.9020408@nets.rwth-aachen.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 4, 2008 at 3:31 PM, Arnd Hannemann
<hannemann@nets.rwth-aachen.de> wrote:
> Hi,
>
>
>  Ilpo J=E4rvinen wrote:
>  > On Tue, 4 Mar 2008, Arnd Hannemann wrote:
>  >
>  >> I'm observing some retransmits with kernel 2.6.24.2, which I don'=
t
>  >> understand. For instance in this cutout[1] of a sequence diagram =
which
>  >> was captured[2] on the TCP sender, 4 retransmits are made.
>  >
>  > They don't correspond to each other?
>
>  Hmm, they should.
>
>
>  >
>  >> According to netstat -st output[3][4] all those 4 retransmits wer=
e "fast
>  >> retransmit".
>  >> But there are no three DUPACKs which I expected would be needed f=
or fast
>  >> retransmit?
>  >
>  > With FACK it's enough that you have fackets_out > tp->reordering
>  > (=3DdupThresh).
>
>  If it is FACK shouldn't it be accounted for LINUX_MIB_TCPFORWARDRETR=
ANS
>  instead of LINUX_MIB_TCPFASTRETRANS?
>
>
>  >
>  >> Also interesting all retransmits happen _after_ those segments we=
re
>  >> already acked and sacked, internal queuing or latency issues?
>  >
>  > I think your viewer is doing something wrong, sender.dump is not g=
iving
>  > such information (or you draw that from wrong end?). Or it just dr=
aws
>  > DSACK like that?
>
>  Viewer is tcptrace and xplot. So nothing special at all.
>  You see it also in wireshark, if you draw a sequence diagram.
>  You also see it in wireshark if you sort by capture timestamp. I alw=
ays thought
>  that capture timestamp order is correct and not dump order, but mayb=
e I'm wrong?
>
>  Tcpdump:
>
>  12:08:20.667538 IP 192.168.0.7.33824 > 192.168.0.5.50139: . ack 2348=
5 win 22720 <nop,nop,timestamp 969759 972885,nop,nop,sack 2 {24905:2632=
5}{27745:29165}>
>  ^^^^^ got acked at .667538
>
>  12:08:20.646749 IP 192.168.0.5.50139 > 192.168.0.7.33824: . 22065:23=
485(1420) ack 1 win 2864 <nop,nop,timestamp 972885 969754>
>  ^^^^^ got retransmitted at .646749
>
>
>  >
>  >> It would be great if somebody could shed some light on this,
>  >> why those segments are retransmitted.
>  >> Dumps and xplots are available here[5].
>  >
>  > ...I quickly glanced over it and found no strange behavior in
>  > the sender.dump.
>
>  Best regards,
>  Arnd
>
>
>
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hi!

I recommend you to capture packages both on sender-side and
receiver-side to verify the tcpdump.

Regards,
Harri
