From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ping: dont call udp_ioctl()
Date: Sun, 15 May 2011 17:44:30 -0400 (EDT)
Message-ID: <20110515.174430.1379973540554096232.davem@davemloft.net>
References: <20110513200100.GA3875@albatros>
	<1305447520.3120.88.camel@edumazet-laptop>
	<20110515213018.GA26820@openwall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, segoon@openwall.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peak@argo.troja.mff.cuni.cz, kees.cook@canonical.com,
	dan.j.rosenberg@gmail.com, eugene@redhat.com, nelhage@ksplice.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: solar@openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1EOVtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 17:49:21 -0400
In-Reply-To: <20110515213018.GA26820@openwall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Solar Designer <solar@openwall.com>
Date: Mon, 16 May 2011 01:30:18 +0400

> On Sun, May 15, 2011 at 10:18:40AM +0200, Eric Dumazet wrote:
>> Do we really need to support SIOCOUTQ and SIOCINQ ioctls for ping
>> sockets ?
> 
> Probably not.
> 
>> BTW, link
>> (ftp://mirrors.kernel.org/openwall/Owl/current/sources/Owl/packages/iputils/iputils-ss020927.tar.gz ) provided in http://openwall.info/wiki/people/segoon/ping is not working.
>> 
>> I had to manually patch iputils-s20101006.tar.bz2 instead.
> 
> Oh, the link broke precisely because we updated to s20101006 since then,
> and the link was to our current branch.  I've just updated the wiki page
> to include links both for iputils-ss020927 and for iputils-s20101006
> (both original tarballs and patches).
> 
>> [PATCH net-next-2.6] net: ping: dont call udp_ioctl()
>> 
>> udp_ioctl() really handles UDP and UDPLite protocols.
>> 
>> 1) It can increment UDP_MIB_INERRORS in case first_packet_length() finds
>> a frame with bad checksum.
>> 
>> 2) It has a dependency on sizeof(struct udphdr), not applicable to
>> ICMP/PING
>> 
>> If ping sockets need to handle SIOCINQ/SIOCOUTQ ioctl, this should be
>> done differently.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Vasiliy Kulikov <segoon@openwall.com>
> 
> Reviewed-by: Solar Designer <solar@openwall.com>

Just get rid of ping_ioctl() entirely, as that is the effect of
this change since inet_ioctl() returns -ENOIOCTLCMD when
sk_prot->ioctl is NULL.

Also get rid of asm/ioctls.h since that will be no longer needed.

Thanks.
