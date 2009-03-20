From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [NET] net: reorder struct net_device_ops
Date: Fri, 20 Mar 2009 13:47:08 +0100
Message-ID: <87iqm4jr8z.fsf@nemi.mork.no>
References: <49C354B5.3060404@cosmosbay.com>
	<20090320.013611.67498837.davem@davemloft.net>
	<49C36570.4010903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37448 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758AbZCTMr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 08:47:58 -0400
In-Reply-To: <49C36570.4010903@cosmosbay.com> (Eric Dumazet's message of "Fri,
	20 Mar 2009 10:44:16 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:

> [NET] net: reorder struct net_device_ops
>
> Moving ndo_start_xmit() field at first position in
> struct net_device_ops reduce the assembly needed to compute
> the prefetch() address.

You can't do this while the compatibility code is still there.

from net/core/dev.c:register_netdevice() :

		/* This works only because net_device_ops and the
		   compatiablity structure are the same. */
		dev->netdev_ops =3D (void *) &(dev->init);


Bj=C3=B8rn
