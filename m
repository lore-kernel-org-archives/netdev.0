From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:37:18 +0100
Message-ID: <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
		 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B5BC.5020103@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:53761 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab1LUKhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:37:22 -0500
Received: by vbbfc26 with SMTP id fc26so5654287vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:37:21 -0800 (PST)
In-Reply-To: <4EF1B5BC.5020103@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:32 +0100, Michal Simek a =C3=
=A9crit :
> Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:28 +0100, Eric Dumazet =
a =C3=A9crit :
> >> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:11 +0100, Michal Simek=
 a =C3=A9crit :
> >>> Hi Eric and David,
> >>>
> >>> I have found one problem with ll_temac driver and
> >>> this commit: net: more accurate skb truesize
> >>> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
> >>>
> >>> The problem is only with icmp packets from the target. It is sent=
 and driver receive it
> >>> but it is not proceed to the application.
> >>>
> >>> The problem I see is that kmalloc_node_track_caller allocate
> >>> specific size and then this size is changed by SKB_WITH_OVERHEAD(=
ksize(data)).
> >>> The problem is with netdev_alloc_skb_ip_align which calls __alloc=
_skb function.
> >>>
> >>> Currently driver uses setting for jumbo frames (9k). When I chang=
e it to use mtu (1,5k) then
> >>> everything is ok.
> >>>
> >>> Can you give me some hints what can be wrong?
> >>>
> >> Is it with SLUB, SLAB or SLOB allocator ?
> >>
> >>
> >=20
> > (I am referring to commit bc417e30f8d
> > (net: Add back alignment for size for __alloc_skb)
>=20
> I have seen that commit. Using the latest&greatest version with this =
patch.
>=20

So after these changes, struct skb_shared_info is located to the very
end of allocated memory.

Maybe there is a problem with MTU=3D9000, since assuming PAGE_SIZE=3D40=
96 on
your machine (is it ?), we have a 16384 bytes block of memory, and
~16000 available in skb head, instead of ~9000
