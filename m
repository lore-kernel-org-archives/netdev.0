From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and
 protect forwarding path against pmtu spoofing
Date: Wed, 08 Jan 2014 01:02:13 -0500 (EST)
Message-ID: <20140108.010213.884915830982848289.davem@davemloft.net>
References: <20140106084827.GA5766@order.stressinduktion.org>
	<20140107.191314.881648861654097224.davem@davemloft.net>
	<20140108050225.GO30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbaAHGCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 01:02:15 -0500
In-Reply-To: <20140108050225.GO30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 8 Jan 2014 06:02:25 +0100

> Hi David!
> 
> On Tue, Jan 07, 2014 at 07:13:14PM -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Mon, 6 Jan 2014 09:48:27 +0100
>> 
>> > +ip_forward_use_pmtu - BOOLEAN
>> > +	By default we don't trust protocol path MTUs while forwarding
>> > +	because they could be easily forged and can lead to unwanted
>> > +	fragmentation by the router.
>> > +	You only need to enable this if you have user-space software
>> > +	which tries to discover path mtus by itself and depends on the
>> > +	kernel honoring this information. This is normally not the
>> > +	case.
>> > +	Default: 0 (disabled)
>> > +	Possible values:
>> > +	0 - disabled
>> > +	1 - enabled
>> 
>> You made this default to off, great, but the description text still says
>> that we don't trust PMTU information by default :-)
> 
> Hm, sorry, but I don't see the contradiction.

You say "By default we don't trust protocol path MTUs", but if the
default value of ip_forward_use_pmtu is zero, we in fact do.
