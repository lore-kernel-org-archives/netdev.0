From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 21:27:44 +0200
Message-ID: <20091016192744.GA18456@1wt.eu>
References: <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli> <4AD84D8B.5020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50291 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303AbZJPT1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 15:27:50 -0400
Content-Disposition: inline
In-Reply-To: <4AD84D8B.5020103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 16, 2009 at 12:40:11PM +0200, Eric Dumazet wrote:
> Julian Anastasov a =E9crit :
> > 	Hello,
> >=20
> > On Fri, 16 Oct 2009, Willy Tarreau wrote:
> >=20
> >>> 	This will need little change in inet_csk_reqsk_queue_prune()
> >>> but it saves SYN-ACK traffic during deferring period in the
> >>> common case when client sends ACK. If such compromise is
> >>> acceptable I can prepare and test some patch.
> >> I would personally like this a lot ! This will satisfy people who
> >> expect it to establish at the end of the "TCP_DEFER_ACCEPT delay"
> >> as can be interpreted from the man page, will reduce the number of
> >> useless SYN-ACKs that annoy other people while still making no
> >> visible change for anyone who would rely on the current behaviour.
> >=20
> > 	OK, I don't have much time now, this is what I'm
> > going to test later today and later can provide proper comments:
> >=20
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
>=20
> I tested both patches and they perform very well, thank you !
>=20
> For the minimum 1 sec value, tcpdump looks like :
> 12:32:03.850456 IP 127.0.0.1.20000 > 127.0.0.1.2222: S 1879889239:187=
9889239(0) win 32792 <mss 16396,nop,nop,timestamp 952803 0,nop,wscale 6=
>
> 12:32:03.850463 IP 127.0.0.1.2222 > 127.0.0.1.20000: S 1890330616:189=
0330616(0) ack 1879889240 win 32768 <mss 16396,nop,nop,timestamp 952803=
 952803,nop,wscale 6>
> 12:32:03.850469 IP 127.0.0.1.20000 > 127.0.0.1.2222: . ack 1 win 513 =
<nop,nop,timestamp 952803 952803>
>=20
> 12:32:06.849989 IP 127.0.0.1.2222 > 127.0.0.1.20000: S 1890330616:189=
0330616(0) ack 1879889240 win 32768 <mss 16396,nop,nop,timestamp 955803=
 952803,nop,wscale 6>
> 12:32:06.849996 IP 127.0.0.1.20000 > 127.0.0.1.2222: . ack 1 win 513 =
<nop,nop,timestamp 955803 955803>
>=20
> So listening application gets the accept() 3 seconds after initial SY=
N

Excellent! Nice work guys.

> # ss -emoian | grep SYN-RECV
> SYN-RECV   0      0                 127.0.0.1:2222             127.0.=
0.1:20000  timer:(on,24sec,4) ino:0 sk:f6f0ec80
>=20
> I wonder if tcp_diag should be extented a bit to reflect fact that th=
e ACK was received from client
> (ie forward the inet_rsk(req)->acked information to idiag_rqueue)

I personally have no opinion on this point.

Thanks!
Willy

