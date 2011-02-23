From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 17:20:20 +0100
Message-ID: <4D6533C4.6000601@trash.net>
References: <20110221160306.GA9650@tuxdriver.com>	 <1298308283.2849.5.camel@edumazet-laptop>	 <1298390536.2861.9.camel@edumazet-laptop>	 <1298474091.3301.364.camel@edumazet-laptop>	 <20110223074305.755c5713@nehalam> <1298477600.3301.367.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab1BWQUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 11:20:23 -0500
In-Reply-To: <1298477600.3301.367.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.02.2011 17:13, schrieb Eric Dumazet:
> Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 07:43 -0800, Stephen Hemminge=
r a =C3=A9crit :
>> On Wed, 23 Feb 2011 16:14:51 +0100
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> 1) SFB default child qdisc is pfifo_fast. It can be changed by anot=
her
>>> qdisc but a child qdisc MUST not drop a packet previously queued. T=
his
>>> is because SFB needs to handle a dequeued packet in order to mainta=
in
>>> its virtual queue states. pfifo_head_drop or CHOKe should not be us=
ed.
>>
>> Why not add a flag field to Qdisc_ops and to mark qdisc's that
>> are (or not) work conserving?
>>
>=20
> That was my initial idea, but have no idea how to implement it (outsi=
de
> of fast path, I mean...)

This also doesn't really have anything to do with work-conserving
qdiscs, SFB f.i. is work conserving, but still might drop other
packets. Actually I don't think there's any qdisc besides the
*fifos that can reasonably be used with SFB, so we might as well
only support a built-in qdisc.

