From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from veth_newlink()
Date: Fri, 22 Apr 2011 11:49:40 +0200
Message-ID: <BANLkTikUAGWhNnCrebQpVttorqVxfD6KWw@mail.gmail.com>
References: <20110124154546.GA2689@psychotron.brq.redhat.com> <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, xemul@openvz.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:36299 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab1DVJuB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 05:50:01 -0400
Received: by qyk7 with SMTP id 7so267086qyk.19
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 02:50:00 -0700 (PDT)
In-Reply-To: <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 22 kwietnia 2011 11:43 u=BFytkownik Micha=B3 Miros=B3aw
<mirqus@gmail.com> napisa=B3:
> 2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>> The code is not needed because tb[IFLA_IFNAME] is already
>> processed in rtnl_newlink(). Remove this redundancy.
> Hi. This patch broke creation of veth devices. Reverting it fixes the=
 issue.
>
> Symptoms:
>
> icybox:~# ip link add type veth
> RTNETLINK answers: File exists
> icybox:~# ip link add type veth peer veth1
> icybox:~# ip addr
> [...]
> 56: D: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
> =A0 =A0link/ether e6:57:58:52:03:50 brd ff:ff:ff:ff:ff:ff
> 57: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen =
1000
> =A0 =A0link/ether c2:c2:a2:d5:d5:3a brd ff:ff:ff:ff:ff:ff

Hmm. I was too quick. Reverting it fixes only first problem - "ip link
add type veth" adds new veth pair now, but "ip link add type veth peer
veth1" gives the same result as above.

Best Regards,
Micha=B3 Miros=B3aw
