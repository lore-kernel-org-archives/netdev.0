From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Wed, 8 Jan 2014 08:10:47 +0100
Message-ID: <20140108071047.GB9007@order.stressinduktion.org>
References: <20140108050225.GO30393@order.stressinduktion.org> <20140108.010213.884915830982848289.davem@davemloft.net> <20140108061320.GA9007@order.stressinduktion.org> <20140108.014940.1139765295618203197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47360 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaAHHKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:10:49 -0500
Content-Disposition: inline
In-Reply-To: <20140108.014940.1139765295618203197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 01:49:40AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 8 Jan 2014 07:13:20 +0100
> 
> > I am sorry..  maybe I am just stupid?
> 
> I thought I was clear about wanting the new behavior to _NOT_ be the
> default.  I thought we agreed on this.

Sorry for not making it clear enough that I changed my mind on this.

I thought that mentioning it in the changelog and after the last
discussion, where I again said that in my opinion this should always be
default behavior unless someone uses a user-space software to discover
MTUs, which normally won't be the case. This is RFC specified and I
never heard a reason why we should do path mtu discovering on a router.
(local connections will still do correct path mtu discovering)

Additionally, given the possible attacks on fragment reassembly, I really
see no point in keeping to use the path mtu for forwarding. The attack
is a new form of the Kaminsky attack on DNS and I think, after it was
shown possible, that this is serious.

I thought I brought all needed arguments last time to make this switch,
I am sorry that I was not stressing these points enough.

I am pretty sure distributions will switch the setting to the mode where
we don't honour path mtu information. This is in fact the only sensible
thing to do.

I personally don't mind the default, I just want the possibility that this can
be documented and people can act accordingly. So I am open for discussion on
the default, but have a strong opinion (and always had) towards not using path
mtu values on forwarding.

Thank you,

  Hannes
