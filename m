From: Li Yu <raise.sail@gmail.com>
Subject: Re: [RFC] tcp: How does SACK or FACK determine the time to start
 fast retransmition?
Date: Thu, 21 Jun 2012 15:20:06 +0800
Message-ID: <4FE2CB26.6010007@gmail.com>
References: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com> <4FE2C03C.6030102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, kernelnewbies@kernelnewbies.org
To: =?UTF-8?B?5p2O5piT?= <lovelylich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56280 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758503Ab2FUHUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 03:20:11 -0400
Received: by dady13 with SMTP id y13so478226dad.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 00:20:11 -0700 (PDT)
In-Reply-To: <4FE2C03C.6030102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8821=E6=97=A5 14:33, =E6=9D=8E=E6=98=93=
 =E5=86=99=E9=81=93:
> HI all,
> When tcp uses reno as its congestion control algothim, it uses
> tp->sacked_out as dup-ack. When the third dup-ack(under default
> condition) comes, tcp will initiate its fast retransmition.
> But how about sack ?
> According to kernel source code comments, when sack or fack tcp optio=
n
> is enabled, there is no dup-ack counter. See comments for function
> tcp_dupack_heuristics():
> http://lxr.linux.no/linux+v2.6.37/net/ipv4/tcp_input.c#L2300
> So , how does tcp know the current dup-ack is the last one which
> triggers the fast retransmition?
>
> According to rfc3517 section 5:
> "Upon the receipt of the first (DupThresh - 1) duplicate ACKs, the
> scoreboard is to be updated as normal."
> "When a TCP sender receives the duplicate ACK corresponding to
> DupThresh ACKs,
> the scoreboard MUST be updated with the new SACK information (via
> Update ()). If no previous loss event has occurred
> on the connection or the cumulative acknowledgment point is beyond
> the last value of RecoveryPoint, a loss recovery phase SHOULD be
> initiated, per the fast retransmit algorithm outlined in [RFC2581]."
>
> But these sentences doesn't describe how tcp knows the current ack
> is the dup-threshold dup-ack.
>
> Accorrding to rfc3517 seciton 4 and isLost(Seqnum) function:
> "The routine returns true when either
> DupThresh discontiguous SACKed sequences have arrived above
> =E2=80=99SeqNum=E2=80=99 or (DupThresh * SMSS) bytes with sequence nu=
mbers greater
> than =E2=80=99SeqNum=E2=80=99 have been SACKed. Otherwise, the routin=
e returns
> false."
> I think this is just what I am searching for, but I still don't know
> which line of code in Linux tcp protocol does this check.
> Can any one help me ? thks in advance.
>
>

Do you mean you did not locate where FR is triggered in TCP stack ?
I am not a TCP expert, however I think that it may be at
tcp_time_to_recover(), and the "DupThresh" is not a fixed value in
Linux TCP implementation.

Thanks

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
