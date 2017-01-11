From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 14:59:09 -0500
Message-ID: <20170111195909.GL24086@oracle.com>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
 <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
 <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        edumazet@google.com, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: "Jonathan T. Leighton" <jtleight@udel.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19321 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752871AbdAKT7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 14:59:30 -0500
Content-Disposition: inline
In-Reply-To: <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/11/17 14:48), Jonathan T. Leighton wrote:
> 
> I would say that an IPv6 socket binds to an IPv4-mapped IPv6
> address, but yes - using it to connect to an IPv6 address would be
> an application bug. It also think that having connect() spend 2
> minutes sending packets containing an illegal source address is a
> bug. (And unfriendly!) I'll look into writing a patch for this, and
> let you know whether or not I think I'm up to it.
> 

BTW, linux probably has a number of bugs in this space. 

you can do a number of "interesting" things, where the
v4-mapped address ends up being treated as a global address.
E.g., you can configure a v4 mapped address on an interface
using /sbin/ip, then you can add an onlink route, like
 # ip -6 route add ::ffff:13.0.0.1 nexthop onlink dev eth1
and you can ping6 ::ffff:13.0.0.1, and (if you do this
on both sides) watch a merry little packet exchange on
the wire, where we send out an NS for ::ffff:13.0.0.1
to the solmcast of the v4 mapped address, the peer politely
responds, and the 2 nodes then have a nice chat. 

I think the RFC states somewhere that you should never ever
send out a v4 mapped address on the wire.

--Sowmini
  
