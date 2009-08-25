From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalive timer problem
Date: Tue, 25 Aug 2009 15:13:16 +0200
Message-ID: <4A93E36C.8070502@gmail.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Li_Xin2@emc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752492AbZHYNNV@vger.kernel.org>
In-Reply-To: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li_Xin2@emc.com a =E9crit :
> Greetings,
>=20
> I found one problem in Linux TCP keepalive timer processing, after
> searching on google, I found Daniel Stempel reported the same problem=
 in
> 2007 (http://lkml.indiana.edu/hypermail/linux/kernel/0702.2/1136.html=
),
> but got no answer. So I have to reraise it.
>=20
> Can anyone help answer this two-years long question?
>=20
>

You should explain your problem in detail, since Daniel one was probabl=
y different.

He mentioned "(timeout is set to e.g. 30 seconds)" which is kind of nas=
ty, given normal one is 7200

If some packets are in flight, keepalive is not fired at all, since nor=
mal
retransmits should take place (check tcp_retries2 sysctl).

TCP Keepalive is only fired when no trafic occurred for a long time, on=
ly if=20
SO_KEEPALIVE socket option was enabled by application.

tcp_retries2 (integer; default: 15)
    The maximum number of times a TCP packet is retransmitted in establ=
ished state
before giving up. The default value is 15, which corresponds to a durat=
ion of
approximately between 13 to 30 minutes, depending on the retransmission=
 timeout.
The RFC 1122 specified minimum limit of 100 seconds is typically deemed=
 too short.=20
