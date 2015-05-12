From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: [PATCH] xen-netfront: reset skb transport header before checksum
Date: Tue, 12 May 2015 07:00:16 -0700 (PDT)
Message-ID: <4f89e3e5-3fa8-4313-b6fb-c68a149508f3@default>
References: <20150512013424.GA7960@oracle.com>
 <1431395493.566.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	davem@davemloft.net, david.vrabel@citrix.com,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	wei.liu2@citrix.com, paul.durrant@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22654 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbbELOA2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:00:28 -0400
In-Reply-To: <1431395493.566.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> This looks bogus for IPv6.
> 
> I would rather fix skb_checksum_setup_ip() and
> skb_checksum_setup_ipv6(), since you already use correctly
> skb_maybe_pull_tail() there.
> 
> In general, setting network and transport header at this point seems
> extra work.
> 

Yes, I missed the IPv6 case. ;-) Thanks Eric for pointing that out.
Looking further the below commit might have already resolved the issue.

commit e5d5decaedf41f5b03e6819789cc3ba8744d9f54
Author: Jason Wang <jasowang@redhat.com>
Date:   Tue Mar 26 23:11:20 2013 +0000

    net: core: let skb_partial_csum_set() set transport header

    For untrusted packets with partial checksum, we need to set the transport he
    for precise packet length estimation. We can just let skb_pratial_csum_set()
    do this to avoid extra call to skb_flow_dissect() and simplify the caller.

    Cc: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Jason Wang <jasowang@redhat.com>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

The guest we were running was older to this and didn't have the above commit.

Thanks.

Venkat
