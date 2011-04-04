From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 04 Apr 2011 22:47:48 +0200
Message-ID: <4D9A2E74.70105@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>	<4D989100.1090207@gmail.com>	<BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>	<4D996B30.3080408@gmail.com>	<20110404071453.GA2791@psychotron.redhat.com>	<4D9A1530.1010102@gmail.com> <m1d3l1eqw8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, Jesse Gross <jesse@kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:56542 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675Ab1DDUrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:47:52 -0400
Received: by wwk4 with SMTP id 4so2072316wwk.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 13:47:50 -0700 (PDT)
In-Reply-To: <m1d3l1eqw8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2011 21:51, Eric W. Biederman a =C3=A9crit :

>
> __netif_receive_skb is actually late for untagging.  eth_type_trans
> would be better but not path of control into __netif_receive_skb
> actually calls eth_type_trans.

Because vlan may nest, we need to keep some sort of frame untagging ins=
ide __netif_receive_skb.

In order to avoid duplicate code, I suggest to manage the first level u=
ntagging (for non hwaccel)=20
the same way we manage other levels of untagging (which are by design n=
on hwaccell).

Hence my proposal to use a rx_handler on the parent device of the vlan =
device, if we know the parent=20
device lack hwaccel vlan handling.

So, instead of trying to mimic the hwaccel path in software, I suggest =
to simply disable software=20
untagging when we know hwaccel untagging is present, by removing (or no=
t installing) the vlan=20
rx_handler from the hwaccel net_device.

Can someone clarify whether hwaccel capable NIC will always untag tagge=
d frames or will only do so=20
if requested at device setup?

	Nicolas.
