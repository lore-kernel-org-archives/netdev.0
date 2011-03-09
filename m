From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Wed, 9 Mar 2011 08:45:48 +0100
Message-ID: <20110309074547.GA2808@psychotron.redhat.com>
References: <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
 <20110306133413.GB2795@psychotron.redhat.com>
 <20110307125059.GA6053@psychotron.brq.redhat.com>
 <20110307224338.GU11864@gospo.rdu.redhat.com>
 <20110308071350.GA2826@psychotron.redhat.com>
 <20110308134247.GW11864@gospo.rdu.redhat.com>
 <4D76A345.9040200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169Ab1CIHqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 02:46:00 -0500
Content-Disposition: inline
In-Reply-To: <4D76A345.9040200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 08, 2011 at 10:44:37PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
>>I'm pretty sure this patch will have the same catastrophic problem yo=
ur
>>last one did.  By cloning and setting skb2->dev =3D orig_dev you just
>>inserted a frame identical to the one we received right back into the
>>stack.  It only took a few minutes for my box to melt as one frame on
>>the wire will cause an infinite number of frames to be received by th=
e
>>stack.
>
>I agree with Andy. We still keep one reinject (netif_rx), which is
>probably better that two (__netif_receive_skb), but not enough.
>
>I really think we need a general framework for late delivery of final
>packets to packet handler registered somewhere in the rx_handler
>path.
>
>Jiri, is this patch the one you announced as "I have some kind nice
>solution in mind and I'm going to submit that as a patch later (too
>many patches are in the wind atm)" ?


I did not had time to verify my thought yet but I think that the only
think needed against my original patch (bonding: move processing of rec=
v
handlers into handle_frame()) is ro remove vlan_on_bond_hook, period.

Because all incoming arps are seen by bond_handle_frame =3D>
bond->recv_probe , even vlan ones - that would make eth0-bond0-bond0.5
work and eth0-bond0-br0-bond0.5 as well. But again, need to verify this=
=2E

Jirka
