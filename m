From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Tue, 31 Jan 2012 14:35:27 +0000
Message-ID: <1328020528.26983.396.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
	 <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:14111 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab2AaOf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:35:29 -0500
In-Reply-To: <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, 2012-01-25 at 13:12 +0000, Eric Dumazet wrote:
> Le mercredi 25 janvier 2012 =C3=A0 13:09 +0000, Ian Campbell a =C3=A9=
crit :
>=20
> > Can you elaborate on the specific benchmark you used there?
>=20
> One machine was sending udp frames on my target (using pktgen)
>=20
> Target was running a mono threaded udp receiver (one socket)

I've been playing with pktgen and I'm seeing more like 81,600-81,800 pp=
s
from a UDP transmitter, measuring on the rx side using "bwm-ng -u
packets" and sinking the traffic with "nc -l -u -p 9 > /dev/null". The
numbers are the same with or without this series.

You mentioned numbers in the 820pps region -- is that really kilo-pps
(in which case I'm an order of magnitude down) or actually 820pps (in
which case I'm somehow a couple of orders of magnitude up).

I'm using a single NIC transmitter, no delay, 1000000 clones of each sk=
b
and I've tried 60 and 1500 byte packets. In the 60 byte case I see more
like 50k pps

I'm in the process of setting up a receiver with a bnx2 but in the
meantime I feel like I'm making some obvious or fundamental flaw in my
method...

Any tips greatly appreciated.

Thanks,
Ian.
