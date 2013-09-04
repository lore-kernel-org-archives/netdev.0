From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GSO/GRO and UDP performance
Date: Wed, 04 Sep 2013 04:53:51 -0700
Message-ID: <1378295631.7360.98.camel@edumazet-glaptop>
References: <52270659.1090208@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:39964 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410Ab3IDLxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 07:53:53 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so194955pbc.4
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 04:53:53 -0700 (PDT)
In-Reply-To: <52270659.1090208@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 04:07 -0600, James Yonan wrote:

> The bundle of UDP packets would traverse the stack as a unit until it 
> reaches the socket layer, where recvmmsg could pass the whole bundle up 
> to userspace in a single transaction (or recvmsg could disaggregate the 
> bundle and pass each datagram individually).

That would require a lot of work, say in netfilter, but also in core
network stack in forwarding, and all UDP users (L2TP, vxlan).

Very unlikely to happen IMHO.

I suspect the performance is coming from aggregation done in user space,
then re-injected into the kernel ?

You could use a kernel module, using udp_encap_enable() and friends.

Check vxlan_socket_create() for an example
