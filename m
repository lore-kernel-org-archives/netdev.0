From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 20:43:06 -0400 (EDT)
Message-ID: <20131028.204306.2213130677400093266.davem@davemloft.net>
References: <20131027164835.GB4714@order.stressinduktion.org>
	<20131028.171725.1076499130782328273.davem@davemloft.net>
	<20131028233158.GA26185@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, vyasevich@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab3J2AnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 20:43:10 -0400
In-Reply-To: <20131028233158.GA26185@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 29 Oct 2013 00:31:58 +0100

> I wonder why NetworkManager rewrote IPv6 router discovery but not IPv4
> DHCP client stuff. It could have been a good moment to introduce something
> like PROT_DHCP sockets. Maybe it is not too late... ;)

Note that you don't even need to put the DHCP protocol core into the
kernel to fix the promiscuous problem.  You just have to use the
current kernel interfaces correctly.

It used to be the case a very long time ago that you couldn't even
receive broadcast UDP datagrams on a socket until an address was
configured on it.

So everyone turns on promiscuous mode and uses RAW sockets or
AF_PACKET.

Stupid?  yes.

But now the kernel will receive broadcast UDP datagrams just fine even
if there are no ipv4 addresses assigned yet.

I did a mock-up simple ipv4 DHCP client implementation just to test it
out, and it did work just fine.  Unfortunately, I can't find it at the
moment, I hope I didn't just delete it in frustration. :-)

> My current idea to handle this, is that a kernel boot parameter is
> provided to stop the generation of link-local addresses and that we kick
> off address configuration from user-space at early as the secret key is
> provided, which may well be from the initramfs. I'll send a RFC as soon
> as I can find some time to clean it up and have it actually tested.

I guess I'm ok with this, as I can't come up with any reasonable
alternative scheme.
