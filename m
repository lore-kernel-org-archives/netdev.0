From: Stefan Berger <stefanb@us.ibm.com>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Mon, 10 May 2010 15:37:00 +0000 (UTC)
Message-ID: <loom.20100510T172617-53@post.gmane.org>
References: <C8083A0F.2EC10%scofeldm@cisco.com> <201005061842.51981.arnd@arndb.de> <201005090120.19958.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:41314 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532Ab0EJQKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 12:10:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OBVYS-0000Xc-ID
	for netdev@vger.kernel.org; Mon, 10 May 2010 18:10:04 +0200
Received: from pool-74-101-125-124.nycmny.fios.verizon.net ([74.101.125.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:10:04 +0200
Received: from stefanb by pool-74-101-125-124.nycmny.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:10:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd <at> arndb.de> writes:

[...]

> +	if (tb[IFLA_VIRTIF]) {
> +		struct ifla_virtif_port_profile *ivp;
> +		struct nlattr *virtif[IFLA_VIRTIF_MAX+1];
> +		u32 vf;
> +
> +		err = nla_parse_nested(virtif, IFLA_VIRTIF_MAX,
> +				       tb[IFLA_VIRTIF], ifla_virtif_policy);
> +		if (err < 0)
> +			return err;
> +
> +		if (!virtif[IFLA_VIRTIF_VF] || !virtif[IFLA_VIRTIF_PORT_PROFILE])
> +			goto novirtif; /* IFLA_VIRTIF may be directed at user space */


In what case would the IFLA_VIRTIF_PORT_PROFILE be provided? Would libvirt for
example need to be aware of whether the Ethernet device can handle the setup
protocol via its firmware and in this case provide the port profile parameter
and in other cases provide other parameters? Certainly the user or upper layer
management software would have to know it when creating the domain XML and in
fact different types of parameters were needed. Obviously we should have one
common set of (XML) parameters that go into the netlink message and that can be
handled by the kernel driver if the firmware knows how to handle it or by
LLDPAD. Libvirt would send the parameters via netlink message to trigger the
setup protocol and the message may be received by kernel and LLDPAD. From what I
can see LLDPAD also may need a way to probe the kernel driver whether it handled
the setup protocol via firmware on a given interface, which may or may not be
true for all interfaces, but may be necessary to avoid triggering the setup
protocol twice.

   Stefan



