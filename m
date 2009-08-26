From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 11:27:43 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908261115140.9933@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org> <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908261006520.9924@gentwo.org>
 <4A954535.2000304@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, sri@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:54225 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750828AbZHZP2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 11:28:09 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3246282CDFE
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 11:29:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4LAjkHcJiyKa for <netdev@vger.kernel.org>;
	Wed, 26 Aug 2009 11:29:10 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 76E3282CE02
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 11:29:05 -0400 (EDT)
In-Reply-To: <4A954535.2000304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009, Eric Dumazet wrote:

> I think it's already done in udp_sendmsg()>
> Code starting at line 765 in net/ipv4/udp.c
>
>         /*
>          * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
>          * ENOBUFS might not be good (it's not tunable per se), but otherwise
>          * we don't have a good statistic (IpOutDiscards but it can be too many
>          * things).  We could add another new stat but at least for now that
>          * seems like overkill.
>          */
>         if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
>                 UDP_INC_STATS_USER(sock_net(sk),
>                                 UDP_MIB_SNDBUFERRORS, is_udplite);
>         }
>

Right. That would mean the fix to ip_push_pending_frames() would also fix
UDP tx drop accounting.

ENOBUFS is then returned for two cases.

1. SNDBUF overflow
2. NIC TX overflow

Hope that is not confusing.



