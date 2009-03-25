From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 20:54:24 +0100
Message-ID: <20090325195424.GB2928@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com> <20090325191850.GA2928@ami.dom.local> <49CA8895.8020105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:64331 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbZCYTzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 15:55:42 -0400
Received: by ti-out-0910.google.com with SMTP id i7so107801tid.23
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 12:55:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49CA8895.8020105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 08:40:05PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
=2E..
> > Alas I'm a bit concerned with virtual devs, e.g. now I'm looking at
> > xmits in macvlan and pppoe. Maybe this patch should exclude them?
> >=20
>=20
> Yes, MACVLAN :) its macvlan_start_xmit() function calls
> dev_queue_xmit(skb) again, so we go back to packet schedulers and
> classifiers, they might need dst again :(
>=20
> Only other potential problem I found was in=20
> drivers/net/appletalk/ipddp.c
>=20
> static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
> {
> __be32 paddr =3D ((struct rtable*)skb->dst)->rt_gateway;
>=20
> Not sure this driver is still supported, or if this paddr can be foun=
d elsewhere...
>  __sk_dst_get(skb->sk) ???
>=20

I guess you've considered the loopback too...

Jarek P.
