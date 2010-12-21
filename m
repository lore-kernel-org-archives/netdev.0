From: "Richard Scheffenegger" <realarms@gmx.at>
Subject: (unknown)
Date: Tue, 21 Dec 2010 11:35:39 +0100
Message-ID: <20101221103539.137960@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:44842 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751240Ab0LUKfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 05:35:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

You may be interested in this draft I recently posted:

http://tools.ietf.org/html/draft-scheffenegger-tcpm-sack-loss-recovery-=
00

It addresses a minor nit-pick fix in the SACK specs, and is a sender-on=
ly modification.=20

Basically, with SACK a sender following RFC3517 will ignore partial ACK=
s as signal that some segments running up to the end-of-stream are lost=
=2E SACK will only recover "known" holes - which means that at least on=
e segment after the lost segment has to be received (and the ACK/SACK f=
or this has to get to the sender).

Under certain circumstances - when the sender is regularly limited in t=
he amount of data to send, either by the application, network (cwnd) or=
 receiver (rwnd), loss of the last segment before RecoveryPoint leads t=
o avoidable RTOs - if the sender would use the partial ack (ACK without=
 any SACK entries, but below RP / snd.max) also as loss indication just=
 as NewReno does. In comparison, using NewReno (disabling SACK), one ca=
n get improved delivery latencies, as partial ACKs trigger a retransmis=
sion with NewReno.

=46or the public internet, I received reports by a major player indicat=
ing a shift between 0.1 and 0.8% from RTOs to fast retransmission (at a=
 overall RTO vs. FastRetransmit ratio of ~60%)

=46or private LANs, which run different applications such as NFS and ve=
ry often stall until one such transaction finishes, I can not provide s=
olid data, but it appears that the impact is more pronounced - but the =
RTO/FR ratio there is typically only 20-40%.


Please let me know what you think about this change.


Richard Scheffenegger

--=20
GMX.at - =C3=96sterreichs FreeMail-Dienst mit =C3=BCber 2 Mio Mitgliede=
rn
E-Mail, SMS & mehr! Kostenlos: http://portal.gmx.net/de/go/atfreemail
