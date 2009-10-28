From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Wed, 28 Oct 2009 13:58:12 +0100
Message-ID: <4AE83FE4.1050309@nets.rwth-aachen.de>
References: <4AE72079.4030504@simula.no> <4AE7262B.1060703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Petlund <apetlund@simula.no>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752934AbZJ1M61@vger.kernel.org>
In-reply-to: <4AE7262B.1060703@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet schrieb:
> Andreas Petlund a =E9crit :
>> This patch will make TCP use only linear timeouts if the stream is t=
hin. This will help to avoid the very high latencies that thin stream s=
uffer because of exponential backoff. This mechanism is only active if =
enabled by iocontrol or syscontrol and the stream is identified as thin=
=2E
>>
>=20
> Wont this reduce the session timeout to something very small, ie 15 r=
etransmits, way under the minute ?

The session timeout no longer depends on the actual number of retransmi=
ts. Instead its a time interval,
which is roughly equivalent to the time a TCP, performing exponential b=
ackoff would need to perform
15 retransmits.

However, addressing the proposal:
I wonder how one can seriously suggest to just skip congestion response=
 during timeout-based
loss recovery? I believe that in a heavily congested scenarios, this wo=
uld lead to a goodput
goodput disaster... Not to mention that in a heavily congested scenario=
, suddenly every flow
will become "thin", so this will even amplify the problems. Or did I mi=
ss something?

Best regards,
Arnd
