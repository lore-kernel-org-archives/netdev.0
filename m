From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Thu, 28 Oct 2010 15:23:29 -0700
Message-ID: <AANLkTim-2ghTVVEaJesMkXcRL-eCPBoHkehKF8HXhyK+@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <4CC78F19.9080504@hp.com> <AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
 <AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com> <AANLkTi=AyYrmSWDTZVWb2s+jgnyjNyHo-fkV4U+Fm45n@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:31732 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab0J1WXw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 18:23:52 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o9SMNpnI026916
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:23:51 -0700
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by hpaq12.eem.corp.google.com with ESMTP id o9SMMTlk017066
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:23:50 -0700
Received: by gxk6 with SMTP id 6so1747837gxk.9
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:23:49 -0700 (PDT)
In-Reply-To: <AANLkTi=AyYrmSWDTZVWb2s+jgnyjNyHo-fkV4U+Fm45n@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 1:39 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> static int __ipv6_regen_rndid(struct inet6_dev *idev) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0get_random_bytes(idev->rndid, sizeof(idev-=
>rndid));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0idev->rndid[0] &=3D ~0x02;
>
> certainly seem to point towards it being totally random.

It's random, but the random interface ID is a property of the
interface, not of the address, and thus survives interface up/down:

# ip -6 a li dev wlan0 secondary
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:1000:fd01:952f:2586:ed6f:408c/64 scope global
secondary dynamic
       valid_lft 604363sec preferred_lft 85363sec
# ip link set wlan0 down
# ip -6 a li dev wlan0 secondary
# ip link set wlan0 up
# ip -6 a li dev wlan0 secondary
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:1000:167d:952f:2586:ed6f:408c/64 scope global
secondary dynamic
       valid_lft 604799sec preferred_lft 85799sec
