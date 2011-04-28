From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next] net: Allow ethtool to set interface in loopback mode.
Date: Thu, 28 Apr 2011 10:20:20 -0700
Message-ID: <BANLkTim4CD4EfZfN5D+SNEctf1V_WNReHQ@mail.gmail.com>
References: <1303347458-14499-1-git-send-email-maheshb@google.com>
	<20110427.230807.48512460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25456 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993Ab1D1RUX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 13:20:23 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3SHKMiT028709
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 10:20:22 -0700
Received: from bwg12 (bwg12.prod.google.com [10.188.7.12])
	by hpaq7.eem.corp.google.com with ESMTP id p3SHIb3F014583
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 10:20:21 -0700
Received: by bwg12 with SMTP id 12so2617926bwg.26
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 10:20:21 -0700 (PDT)
In-Reply-To: <20110427.230807.48512460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2011 at 11:08 PM, David Miller <davem@davemloft.net> wr=
ote:
>
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Wed, 20 Apr 2011 17:57:38 -0700
>
> > This patch enables ethtool to set the loopback mode on a given inte=
rface.
> > By configuring the interface in loopback mode in conjunction with a=
 policy
> > route / rule, a userland application can stress the egress / ingres=
s path
> > exposing the flows of the change in progress and potentially help d=
eveloper(s)
> > understand the impact of those changes without even sending a packe=
t out
> > on the network.
> >
> > Following set of commands illustrates one such example -
> > =A0 =A0 a) ip -4 addr add 192.168.1.1/24 dev eth1
> > =A0 =A0 b) ip -4 rule add from all iif eth1 lookup 250
> > =A0 =A0 c) ip -4 route add local 0/0 dev lo proto kernel scope host=
 table 250
> > =A0 =A0 d) arp -Ds 192.168.1.100 eth1
> > =A0 =A0 e) arp -Ds 192.168.1.200 eth1
> > =A0 =A0 f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
> > =A0 =A0 g) sysctl -w net.ipv4.conf.all.accept_local=3D1
> > =A0 =A0 # Assuming that the machine has 8 cores
> > =A0 =A0 h) taskset 000f netserver -L 192.168.1.200
> > =A0 =A0 i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.=
168.1.200 -l 30
> >
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> It's impossible to evaluate this patch without you also showing us so=
me
> users.
>
My apologies. I'll post one such case/patch immediately.

--mahesh..

> I'm not applying this.
