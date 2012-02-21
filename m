From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 22:48:16 +0100
Message-ID: <1329860896.18384.61.camel@edumazet-laptop>
References: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65109 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab2BUVsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:48:21 -0500
Received: by werb13 with SMTP id b13so4103523wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 13:48:20 -0800 (PST)
In-Reply-To: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 12:47 -0800, Greg Rose a =C3=A9cri=
t :

> Modifies the rtnl_calcit function to traverse the list of net
> devices and compute the minimum buffer size that can hold the
> info dumps of all matching devices based upon the filter passed
> in via the new netlink attribute filter mask.  If no filter
> mask is sent then the buffer allocation defaults to NLMSG_GOODSIZE.
>=20

=2E..

> +	/*
> +	 * traverse the list of net devices and compute the minimum
> +	 * buffer size based upon the filter mask.
> +	 */
> +	list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list) {
> +		min_ifinfo_dump_size =3D max_t(u16, min_ifinfo_dump_size,
> +					     if_nlmsg_size(dev,
> +						           ext_filter_mask));
> +	}

Thats going to hurt some setups (thousand of devices on a server).

Also why are you using _rcu() variant here, we hold rtnl I presume ?
