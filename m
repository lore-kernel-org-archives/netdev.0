From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Fwd: Regarding to your linux kernel CL
Date: Tue, 5 Oct 2010 09:42:37 -0700
Message-ID: <AANLkTinoAh=MOOnPM1nJhq+tXAxFC2zia0YH49UwN9+b@mail.gmail.com>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:17924 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420Ab0JEQnB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 12:43:01 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o95GgxRT018454
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 09:42:59 -0700
Received: from qyk8 (qyk8.prod.google.com [10.241.83.136])
	by hpaq3.eem.corp.google.com with ESMTP id o95GfnfC019284
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 09:42:58 -0700
Received: by qyk8 with SMTP id 8so5079621qyk.6
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 09:42:58 -0700 (PDT)
In-Reply-To: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have an issue with the CL
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dd11a4dc18bf41719c9f0d7ed494d295dd2973b92.
Please see the original mail below. Any comment?

Thanks,
Chung-yih


---------- Forwarded message ----------
=46rom: Chung-Yih Wang (=E7=8E=8B=E5=B4=87=E6=87=BF) <cywang@google.com=
>
Date: Mon, Oct 4, 2010 at 6:23 PM
Subject: Regarding to your linux kernel CL
To: timo.teras@iki.fi
Cc: herbert@gondor.apana.org.au, davem@davemloft.net


Hi Timo,

=C2=A0 =C2=A0I encountered an issue with your CL
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dd11a4dc18bf41719c9f0d7ed494d295dd2973b92.
The cause is that we use a connected UDP socket for building the
l2tp/ipsec vpn connection. However, when the ipsec tunnel is built,
your CL made the sk_dst_check useless(since it always return the
'freed' dst_entry and can not reset the dst entry for the socket).
What is your comment to conquer this issue?

Solution 1. We could add a CL to change it to (dst && dst->obsolete &&
(dst->obsolete>0 =C2=A0|| dst->ops->check(...)=3D=3DNULL) in sk_dst_che=
ck()) ?

Solution 2. Revert the change?

Any comment?

Thanks,
Chung-yih
