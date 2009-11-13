From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 15:32:29 -0800
Message-ID: <20091113153229.408c889f@nehalam>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	<20091113074508.GA6605@ff.dom.local>
	<412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	<20091113091825.GA7449@ff.dom.local>
	<412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
	<20091113081553.0568296c@s6510>
	<412e6f7f0911131528i3105648y49213143e12f2522@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57657 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932450AbZKMXcp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 18:32:45 -0500
In-Reply-To: <412e6f7f0911131528i3105648y49213143e12f2522@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Nov 2009 07:28:42 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Sat, Nov 14, 2009 at 12:15 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Fri, 13 Nov 2009 17:38:56 +0800
> > Changli Gao <xiaosuo@gmail.com> wrote:
> >>
> >> Oh, :) . I know more than one companies use kernel threads to forw=
ard
> >> packets, and there isn't explicit extra overhead at all. And as yo=
u
> >> know, as throughput increases, NAPI will bind the NIC to a CPU, an=
d
> >> softirqd will be waked up to do the work, which should be done in
> >> SoftIRQ context. At that time, there isn't any difference between =
my
> >> approach and the current kernel's.
> >>
> > Why not make IFB a NAPI device. This would get rid of the extra sof=
t-irq
> > round trip from going through netif_rx(). =C2=A0It would also behav=
e like
> > regular multi-queue recieive device, and eliminate need for seperat=
e
> > tasklets or threads.
> >
>=20
> It needs to send remote SoftIRQ, as Receiving Packet Steering, and we
> must support a extra interface to map load to CPUs.
>=20

But it still could use NAPI to avoid causing excess packet overhead.
The softirq could be equivalent of hardirq in network device.

--=20
