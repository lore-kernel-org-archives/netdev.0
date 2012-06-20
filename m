From: LovelyLich <lovelylich@gmail.com>
Subject: How does SACK or FACK determine the time to start fast retransmition?
Date: Wed, 20 Jun 2012 22:31:03 +0800
Message-ID: <CAAA3+BpRQ24HED6a+yCF+A_q=vJ7nHexLJd1U+-50pb43MVa5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HI all,
    When tcp uses reno as its congestion control algothim, it uses
tp->sacked_out as dup-ack. When the third dup-ack(under default
condition) comes, tcp will initiate its fast retransmition.
    But how about sack ?
    According to kernel source code comments, when sack or fack tcp opt=
ion
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
=92SeqNum=92 or (DupThresh * SMSS) bytes with sequence numbers greater
than =92SeqNum=92 have been SACKed. Otherwise, the routine returns
false."
    I think this is just what I am searching for, but I still don't kno=
w
which line of code in Linux tcp protocol does this check.
    Can any one help me ? thks in advance.
