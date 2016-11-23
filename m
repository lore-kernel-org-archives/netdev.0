From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 23 Nov 2016 04:05:29 -0800
Message-ID: <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
         <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yuehaibing <yuehaibing@huawei.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33967 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933829AbcKWMFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:05:31 -0500
Received: by mail-pg0-f45.google.com with SMTP id x23so5635334pgx.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 04:05:31 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-23 at 10:33 +0200, Julian Anastasov wrote:
> 	Hello,
> 
> On Wed, 23 Nov 2016, yuehaibing wrote:
> 
> > 	As to my topo,HOST1 and HOST3 share one route on HOST2, tcp connection between HOST2 and HOST3 may call tcp_ack to set dst->pending_confirm.
> > 	
> > So dst_neigh_output may wrongly freshed  n->confirmed which stands for HOST1,however HOST1'MAC had been changed.
> > 
> > 	The possibility of this occurred Significantly increases ,when ping and TCP transaction are set the same processor affinity on the HOST2.
> > 
> > 	It seems that the issue is brought in commit 5110effee8fde2edfacac9cd12a9960ab2dc39ea ("net: Do delayed neigh confirmation.").
> 
> 	Bad news. Problem is not in delayed confirmation but
> in the mechanism to use same dst for different neighbours on
> LAN. We don't have a dst->neighbour reference anymore.
> 
> 	For IPv4 this is related to rt->rt_uses_gateway but
> also to DST_NOCACHE. In the other cases we can not call
> dst_confirm, may be we should lookup the neigh entry instead.
> But we need a way to reduce such lookups on every packet,
> for example, by remembering in struct sock and checking if
> some bits of jiffies (at least 4-5) are changed from
> previous lookup.


I thought bonding would keep the MAC address 'alive'.

If TCP packets are confirmed, this means the old MAC address is still
valid, what am I missing here ?
