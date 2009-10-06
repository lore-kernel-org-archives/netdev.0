From: Ben Greear <greearb@candelatech.com>
Subject: Re: Support of multiple default routes in Linux ?
Date: Tue, 06 Oct 2009 11:02:15 -0700
Message-ID: <4ACB8627.6000202@candelatech.com>
References: <9041a1390910060837g1a536bc3x624cc6a5026af83d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Mallika Gautam <mallika.gautam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34324 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbZJFSCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 14:02:54 -0400
In-Reply-To: <9041a1390910060837g1a536bc3x624cc6a5026af83d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2009 08:37 AM, Mallika Gautam wrote:
> Hi All,
>
> I am working on 2.6.26 kernel. I am trying to setup Policy based
> routing with multiple IP addresses in same subnet, with multiple
> routing tables, each having its own default gateway. I have no route
> in the 'Main' table. Problem is that I am not able to add default
> route in each of the routing table.
>
> I have 3 interfaces in the same subnet, sharing the gateway. I am
> using 3 different routing tables for them. I need to add this gateway
> to each of the routing tables with different interface associated with
> the routing table.
>
> Routing tables look like this -
>
> eth0: 192.168.1.1/16
> eth1: 192.168.1.2/16
> eth2: 192.168.1.3/16
>
> main table: empty
>
> ---- eth0tbl: routing table for eth0 ----
> 192.168.0.0/16 dev eth0
>
> --- eth1tbl: routing table for eth1 ---
> 192.168.0.0/16 dev eth1
>
> --- eth2tbl: routing table for eth2 ---
> 192.168.0.0/16 dev eth2
>
> #ip rule
> 0: from all lookup local
> 2: from 192.168.1.1 iif lo lookup eth0tbl
> 3: from all to 192.168.1.1 iif eth0 lookup eth0tbl
> 4: from 192.168.1.2 iif lo lookup eth1tbl
> 5: from all to 192.168.1.2 iif eth1 lookup eth1tbl
> 6: from 192.168.1.3 iif lo lookup eth2tbl
> 7: from all to 192.168.1.3 iif eth2 lookup eth2tbl
> 32766: from all lookup main ---------->  /* empty */
> 32767: from all lookup default ---------->  /* empty */
>
> when I give following command to add default route, it returns error -
> #ip route add default via 192.168.254.254 dev eth0 table eth0tbl
> RTNETLINK answers: No such process.
>
> #ip route add default via 192.168.254.254 dev eth1 table eth1tbl
> RTNETLINK answers: No such process.
>
> #ip route add default via 192.168.254.254 dev eth2 table eth2tbl
> RTNETLINK answers: No such process.
>
> arp_announce, arp_ignore and arp_filter are all set to 1.
> Is there a way this can be achieved? Is this available in any of the
> later kernel versions? Any pointers would be of help.

Try adding subnet routes first?  This can work, as we do it all
the time.

We also use numeric tags for table-id, but no idea if that is an issue.

Ben

>
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

