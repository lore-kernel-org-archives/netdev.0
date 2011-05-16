From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Null pointer dereference in icmp_send
Date: Mon, 16 May 2011 23:27:16 +0200
Message-ID: <1305581236.9466.4.camel@edumazet-laptop>
References: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roberto.paleari@emaze.net
To: Aristide Fattori <joystick@security.dico.unimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:61916 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756409Ab1EPV1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:27:21 -0400
Received: by wwk4 with SMTP id 4so3015354wwk.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 14:27:20 -0700 (PDT)
In-Reply-To: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 mai 2011 =C3=A0 23:06 +0200, Aristide Fattori a =C3=A9crit =
:
> Hi everybody,
>=20
> in function icmp_send() (net/ipv4/icmp.c), the parameter passed to
> dev_net() function is not properly validated. This can lead to a NULL
> pointer dereference that crashes the kernel. The bug can be triggered
> remotely, by flooding the target with fragmented IPv4 packets.
> Important fields in the IP packet are:
>  * Flags: the MF flag must be set.
>  * Fragment ID: using pseudo-random values for this field quickly
> fills fragmented queues in the victim's kernel, as it is unable to
> easily reassemble received packets.
>  * TOS: using pseudo-random values for this field triggers the
> creation of more than one route cache entry for the same destination
> address, increasing the chances of incurring in the error condition
> described before.
> Other fields of the packet do not really matter, and they can be set
> to arbitrary values.
>=20
> If you are interested, we can provide a small and very dirty python
> script that easily triggers the error condition.
>=20

Hi

You forgot to tell us which linux version you used ?

We had some fixes lately in this area.

Thanks


