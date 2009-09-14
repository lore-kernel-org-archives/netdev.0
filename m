From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 13:10:13 +0300
Message-ID: <20090914101012.GA14176@redhat.com>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com> <20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900AbZINKL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 06:11:58 -0400
Content-Disposition: inline
In-Reply-To: <4AAE1026.4090702@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 12:43:02PM +0300, Or Gerlitz wrote:
> Michael S. Tsirkin wrote:
>> That's already possible. However virtualization users are familiar
>> with configuring the tun device, and tun has grown
>> virtualization-specific extensions, so I don't see a reason not to
>> accomodate these uses
> Today packets are written/read from/to Qemu to/from tun device, how  
> would the use case with vhost will look like?

- Configure bridge and tun using existing scripts
- pass tun fd to vhost via an ioctl
- vhost calls tun_get_socket
- from this point, guest networking just goes faster

> Is this the user setting an uplink NIC + bridge + per VM tun device but  
> the packets will go from/to virtio-net in the guest kernel to/from vhost  
> in the host kernel and then from/to vhost to/from tun? so eventually no  
> packets will be seen by the qemu process? I don't see what these scheme  
> buys people, I got very much confused.
>
> Or.

A lot of people have asked for tun support in vhost, because qemu
currently uses tun.  With this scheme existing code and scripts can be
used to configure both tun and bridge.  You also can utilize
virtualization-specific features in tun.

-- 
MST
