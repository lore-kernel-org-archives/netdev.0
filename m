From: Cedric Le Goater <legoater@free.fr>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Sat, 29 Sep 2007 16:55:13 +0200
Message-ID: <46FE6751.3050205@free.fr>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org> <46FD20F0.3050909@fr.ibm.com> <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi> <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:55461 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbXI2O5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 10:57:17 -0400
In-Reply-To: <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Fri, 28 Sep 2007, Ilpo J=E4rvinen wrote:
>> On Fri, 28 Sep 2007, Cedric Le Goater wrote:
>>
>>> I just found that warning in my logs. It seems that it's been=20
>>> happening since rc7-mm1 at least.=20
>>>
>>> WARNING: at /home/legoater/linux/2.6.23-rc8-mm2/net/ipv4/tcp_input.=
c:2314 tcp_fastretrans_alert()
>>>
>>> Call Trace:
>>>  <IRQ>  [<ffffffff8040fdc3>] tcp_ack+0xcd6/0x1894
>>> ...snip...
>> ...Thanks for the report, I'll have look what could still break=20
>> fackets_out...
>=20
> I think this one is now clear to me, tcp_fragment/collapse adjusts=20
> fackets_out (incorrectly) also for reno flow when there were some dup=
ACKs=20
> that made sacked_out !=3D 0. Could you please try if patch below prov=
es all=20
> them to be of non-SACK origin... In case that's true, it's rather=20
> harmless, I'll send a fix on Monday or so (this would anyway be neede=
d)...=20
> If you find out that them occur with SACK enabled flow, that would be
> more interesting and requires more digging...

I'm trying now to reproduce this WARNING.=20

It seems that the n/w behaves differently during the week ends. Probabl=
y
taking a break.=20

C.
