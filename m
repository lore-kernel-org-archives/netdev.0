From: =?UTF-8?B?5p2O5piT?= <lovelylich@gmail.com>
Subject: [RFC] tcp: How does SACK or FACK determine the time to start fast
 retransmition?
Date: Thu, 21 Jun 2012 14:33:32 +0800
Message-ID: <4FE2C03C.6030102@gmail.com>
References: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernelnewbies@kernelnewbies.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:41136 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab2FUGds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 02:33:48 -0400
Received: by dady13 with SMTP id y13so426660dad.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 23:33:48 -0700 (PDT)
In-Reply-To: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI all,
     When tcp uses reno as its congestion control algothim, it uses
tp->sacked_out as dup-ack. When the third dup-ack(under default
condition) comes, tcp will initiate its fast retransmition.
     But how about sack ?
     According to kernel source code comments, when sack or fack tcp op=
tion
is enabled, there is no dup-ack counter. See comments for function
tcp_dupack_heuristics():
http://lxr.linux.no/linux+v2.6.37/net/ipv4/tcp_input.c#L2300
     So , how does tcp know the current dup-ack is the last one which
triggers the fast retransmition?

     According to rfc3517 section 5:
     "Upon the receipt of the first (DupThresh - 1) duplicate ACKs, the
scoreboard is to be updated as normal."
     "When a TCP sender receives the duplicate ACK corresponding to
DupThresh ACKs,
the scoreboard MUST be updated with the new SACK information (via
Update ()). If no previous loss event has occurred
on the connection or the cumulative acknowledgment point is beyond
the last value of RecoveryPoint, a loss recovery phase SHOULD be
initiated, per the fast retransmit algorithm outlined in [RFC2581]."

     But these sentences doesn't describe how tcp knows the current ack
is the dup-threshold dup-ack.

     Accorrding to rfc3517 seciton 4 and isLost(Seqnum) function:
     "The routine returns true when either
DupThresh discontiguous SACKed sequences have arrived above
=E2=80=99SeqNum=E2=80=99 or (DupThresh * SMSS) bytes with sequence numb=
ers greater
than =E2=80=99SeqNum=E2=80=99 have been SACKed. Otherwise, the routine =
returns
false."
     I think this is just what I am searching for, but I still don't kn=
ow
which line of code in Linux tcp protocol does this check.
     Can any one help me ? thks in advance.
