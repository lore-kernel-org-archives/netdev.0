From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 1 Feb 2012 09:39:47 +0000
Message-ID: <1328089187.17444.10.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
	 <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328020528.26983.396.camel@zakaz.uk.xensource.com>
	 <1328021140.2297.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:25136 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab2BAJjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 04:39:49 -0500
In-Reply-To: <1328021140.2297.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 14:45 +0000, Eric Dumazet wrote:
> Le mardi 31 janvier 2012 =C3=A0 14:35 +0000, Ian Campbell a =C3=A9cri=
t :
> > Hi Eric,
> >=20
> > On Wed, 2012-01-25 at 13:12 +0000, Eric Dumazet wrote:
> > > Le mercredi 25 janvier 2012 =C3=A0 13:09 +0000, Ian Campbell a =C3=
=A9crit :
> > >=20
> > > > Can you elaborate on the specific benchmark you used there?
> > >=20
> > > One machine was sending udp frames on my target (using pktgen)
> > >=20
> > > Target was running a mono threaded udp receiver (one socket)
> >=20
> > I've been playing with pktgen and I'm seeing more like 81,600-81,80=
0 pps
> > from a UDP transmitter, measuring on the rx side using "bwm-ng -u
> > packets" and sinking the traffic with "nc -l -u -p 9 > /dev/null". =
The
> > numbers are the same with or without this series.
> >=20
> > You mentioned numbers in the 820pps region -- is that really kilo-p=
ps
> > (in which case I'm an order of magnitude down) or actually 820pps (=
in
> > which case I'm somehow a couple of orders of magnitude up).
> >=20
> > I'm using a single NIC transmitter, no delay, 1000000 clones of eac=
h skb
> > and I've tried 60 and 1500 byte packets. In the 60 byte case I see =
more
> > like 50k pps
> >=20
> > I'm in the process of setting up a receiver with a bnx2 but in the
> > meantime I feel like I'm making some obvious or fundamental flaw in=
 my
> > method...
> >=20
> > Any tips greatly appreciated.
>=20
> I confirm I reach 820.000 packets per second, on a Gigabit link.

Heh, this is where $LOCALE steps up and confuses things again (commas v=
s
periods for thousands separators) ;-). However I know what you mean.

> Sender can easily reach line rate (more than 1.000.000 packets per
> second)

Right, this is where I seem to have failed -- 10,000,000 took more like
2 minutes to send than the expected 10s...

> Check how many packet drops you have on receiver ?
>=20
> ifconfig eth0
>=20
> or "ethtool -S eth0"

After a full 10,000,000 packet run of pktgen I see a difference in
rx_packets of +10,001,561 (there is some other traffic). Various
rx_*_error do not increase and neither does rx_no_buffer_count or
rx_missed_errors (although both of the latter two are non-zero to start
with). ifconfig tells the same story.

I guess this isn't surprising given the send rate since it's not really
stressing the receiver all that much.

I'll investigate the sending side. The sender is running a 2.6.32 distr=
o
kernel. Maybe I need to tweak it somewhat.

Thanks,

Ian.
