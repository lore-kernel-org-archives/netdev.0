From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Sat, 30 Apr 2011 11:02:02 +0200
Message-ID: <20110430090201.GB2658@psychotron.orion>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
 <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, xemul@openvz.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753674Ab1D3JCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2011 05:02:09 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Apr 22, 2011 at 11:43:10AM CEST, mirqus@gmail.com wrote:
>2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>> The code is not needed because tb[IFLA_IFNAME] is already
>> processed in rtnl_newlink(). Remove this redundancy.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Hi. This patch broke creation of veth devices. Reverting it fixes the =
issue.
>
>Symptoms:
>
>icybox:~# ip link add type veth
>RTNETLINK answers: File exists
>icybox:~# ip link add type veth peer veth1
>icybox:~# ip addr
>[...]
>56: D: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>    link/ether e6:57:58:52:03:50 brd ff:ff:ff:ff:ff:ff
>57: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1=
000
>    link/ether c2:c2:a2:d5:d5:3a brd ff:ff:ff:ff:ff:ff

interesting, on net-next I get following with or without this patch
applied:

[root@f14 ~]# ip link add type veth peer veth1
Error: either "dev" is duplicate, or "veth1" is a garbage.

Trying original F14 ip and currect git one gives the same

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
