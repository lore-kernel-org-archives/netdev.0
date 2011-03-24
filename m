From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression: ip r change mss doesn't work in 2.6.38-git14
Date: Thu, 24 Mar 2011 16:21:58 +0100
Message-ID: <1300980118.3747.42.camel@edumazet-laptop>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57449 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab1CXPWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 11:22:49 -0400
In-Reply-To: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 mars 2011 =C3=A0 16:08 +0100, Alessandro Suardi a =C3=A9cri=
t :
> After fixing the display issue thanks to Chris Wilson, I now have
> another problem
>  (which didn't exist in 2.6.38-git2); most websites outside of my DSL=
 link don't
>  work properly (connection packet goes through, but the page load tim=
es out
>  within Firefox) unless I do
>=20
> ip r change default via 192.168.1.1 dev eth1 advmss 1400
>=20
> This however doesn't change advmss anymore:
>=20
> [root@duff ~]# ip r
> default via 192.168.1.1 dev eth1
> 169.254.0.0/16 dev eth1  scope link  metric 1004
> 192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.8
> [root@duff ~]# ip r change default via 192.168.1.1 dev eth1 advmss 14=
00
> [root@duff ~]# ip r
> default via 192.168.1.1 dev eth1
> 169.254.0.0/16 dev eth1  scope link  metric 1004
> 192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.8

Indeed, we'll take a look, thanks for the report.

In the time being you can do :

ip ro change default via 192.168.1.1 dev eth1 advmss 1400 mtu 1500


