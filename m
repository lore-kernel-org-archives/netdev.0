From: Patrick McHardy <kaber@trash.net>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 15:43:41 +0200
Message-ID: <463B388D.806@trash.net>
References: <20070504132934.GD2291@2ka.mipt.ru>  <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com> <11217.1178285625@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbXEDNoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 09:44:05 -0400
In-Reply-To: <11217.1178285625@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
> {
> 	struct rtable *rt;
> 	struct flowi fl;
> 	int ret;
> 
> 	peer->if_mtu = 1500;
> 
> 	memset(&fl, 0, sizeof(fl));
> 
> 	switch (peer->srx.transport.family) {
> 	case AF_INET:
> 		fl.oif = 0;
> 		fl.proto = IPPROTO_UDP,
> 		fl.nl_u.ip4_u.saddr = 0;
> 		fl.nl_u.ip4_u.daddr = peer->srx.transport.sin.sin_addr.s_addr;
> 		fl.nl_u.ip4_u.tos = 0;
> 		/* assume AFS.CM talking to AFS.FS */
> 		fl.uli_u.ports.sport = htonl(7001);
> 		fl.uli_u.ports.dport = htonl(7000);

htons()

> 		break;
> 	default:
> 		BUG();
> 	}
> 
> 	ret = ip_route_output_key(&rt, &fl);
> 	if (ret < 0) {
> 		kleave(" [route err %d]", ret);
> 		return;
> 	}
> 
> 	peer->if_mtu = dst_mtu(&rt->u.dst);


You need dst_release(&rt->u.dst) here.
