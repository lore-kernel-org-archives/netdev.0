From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 09:18:54 +0000
Message-ID: <20090902091854.GA6530@ff.dom.local>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51268 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbZIBJS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 05:18:59 -0400
Received: by fxm17 with SMTP id 17so631370fxm.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 02:18:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9E2CC7.1010103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2009 at 10:28:55AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > [Resent with fixed netdev@ address]
> >=20
> > On 02-09-2009 01:52, Christoph Lameter wrote:
> >> [NET] Add proc file to display the state of all qdiscs
> >>
> >> TC is a complicated tool and it currently does not allow the displ=
ay of all
> >> qdisc states. It does not support multiple tx queues and also not
> >> localhost, nor does it display the current operating state of the =
queues.
> >=20
> > I think, tc should've no problem with displaying summary stats of
> > multiqueue qdiscs or even all of them separately, as mentioned by
> > Patrick. And, maybe I still miss something, but there should be
> > nothing special with tc vs. localhost either.
> >
>=20
> I made a patch, but for a 8 queue device (bnx2), here is the "tc -s -=
d qdisc" result :
>=20
> $ tc -s -d qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 51814 bytes 459 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
>=20
> Same name "eth0" is displayed, that might confuse parsers...
>=20
> What naming convention should we choose for multiqueue devices ?
>=20

Hmm... anything could break here something for somebody, so there is
still a (Patrick's) question if not sum it all? Otherwise, I wonder
about using the qdisc handle (tcm_handle>>16): there would be at
least one "pfifo_fast 0:" looking like proper root for somebody...

Jarek P.
