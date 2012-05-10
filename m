From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: FW: PROBLEM: VLAN LRO issue
Date: Thu, 10 May 2012 03:25:47 +0200
Message-ID: <1336613147.12504.124.camel@edumazet-glaptop>
References: <599E416D1C5C994980C45977191D726906AB2FE86E@MTKMBS03.mediatek.inc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steven Liu =?UTF-8?Q?=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46616 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338Ab2EJBZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 21:25:51 -0400
Received: by wgbdr13 with SMTP id dr13so834894wgb.1
        for <netdev@vger.kernel.org>; Wed, 09 May 2012 18:25:50 -0700 (PDT)
In-Reply-To: <599E416D1C5C994980C45977191D726906AB2FE86E@MTKMBS03.mediatek.inc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 09:01 +0800, Steven Liu (=E5=8A=89=E4=BA=BA=E8=B1=
=AA) wrote:
> Hi Sir,
>=20
> I found the issue about VLAN LRO feature and below is bug description=
 and patch for your reference, thanks.
>=20
> [1.] One line summary of the problem:=20
> VLAN LRO issue
>=20
> [2.] Full description of the problem/report:
> LRO implementation cannot handle VLAN tagged packets correctly.
> It uses correct packet length when creating new LRO session, but uses=
 wrong packet length when putting following packets into exist LRO sess=
ion.
>=20
> [3.] Keywords (i.e., modules, networking, kernel):
> Networking
>=20
> [4.] Kernel version (from /proc/version):
> Linux-3.4-rc3 and below
>=20
> [5.] Output of Oops.. message (if applicable) with symbolic informati=
on
>      resolved (see Documentation/oops-tracing.txt) System is still wo=
rking, but cannot speed up VLAN tagged traffic.
>=20
> [X.] Other notes, patches, fixes, workarounds:
> We have to apply below patch to fix this issue.
>=20
> --- linux-3.4-rc3/net/ipv4/inet_lro.orig        2012-05-08 20:09:44.8=
10366089 +0800
> +++ linux-3.4-rc3/net/ipv4/inet_lro.c   2012-05-08 20:09:33.331679419=
 +0800
> @@ -353,7 +353,7 @@ static int __lro_proc_skb(struct net_lro
>         if (lro_desc->tcp_next_seq !=3D ntohl(tcph->seq))
>                 goto out2;
>=20
> -       if (lro_tcp_ip_check(iph, tcph, skb->len, lro_desc))
> +       if (lro_tcp_ip_check(iph, tcph, skb->len - vlan_hdr_len, lro_=
desc))
>                 goto out2;
>=20
>         lro_add_packet(lro_desc, skb, iph, tcph);
>=20

Hi=20

This looks like a good fix, could you please submit an official patch ?

Documentation/SubmittingPatches
