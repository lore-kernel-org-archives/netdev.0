From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: Cascading Bond devices
Date: Fri, 7 Feb 2014 16:27:52 +0800
Message-ID: <52F49908.7050901@huawei.com>
References: <20140207074149.GA17815@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Thomas Glanzmann <thomas@glanzmann.de>,
	Linux Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19328 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaBGI3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 03:29:08 -0500
In-Reply-To: <20140207074149.GA17815@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/7 15:41, Thomas Glanzmann wrote:
> Hello,
> I wonder if it is possible to cascade bond devices. I have currently =
a
> box with four network cards. Two are going to switch a and two are go=
ing
> to switchb. And what I would like to do is the following:
>=20
> switch-01 port 1 - eth0 \
> switch-01 port 2 - eth1 - bond0 (802.3ad Layer 2 hash) \
> switch-02 port 1 - eth2 - bond1 (802.3ad Layer 2 hash) - bond2 (activ=
e-passive)
> switch-02 port 2 - eth3 /
>=20
> If it is possible, how would I configure such a scenario? bond0 and
> bond1 is easy and in fact I already have them. But I don't get howto =
to
> use adifferent hashing algorithm for bond2.
>=20

Hi Thomas:

bond2 (active-passive)=EF=BC=9F if you mean active-backup,
I think this situation will work well, and I test it by two card:

 switch-01 port 2 - eth1 - bond0 (802.3ad Layer 2 hash) \
 switch-02 port 1 - eth2 - bond1 (802.3ad Layer 2 hash) - bond2 (active=
-backup)=20

the bond2 could work.

> I also wanted to use tlb/alb in the past but experienced broadcast
> storms when using IPv6 on such devices. Also I was not able to set an
> IPv6 address because of duplicated address detection told me that it =
was
> already online on the subnet which it was not. This was with kernel 3=
=2E12
> and 3.13.
>=20

I think you have to reset ipv6 address yourself.

Ding

> Cheers,
>         Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
