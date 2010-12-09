From: Stefan Berger <stefanb@us.ibm.com>
Subject: Re: [RFC][net-next-2.6 PATCH 0/2] rtnetlink: New =?utf-8?b?SUZMQV9QT1JUX1BST1RPXyo=?= attr
Date: Thu, 9 Dec 2010 13:33:33 +0000 (UTC)
Message-ID: <loom.20101209T141255-700@post.gmane.org>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39508 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab0LINdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 08:33:49 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PQgd1-0000zx-Ia
	for netdev@vger.kernel.org; Thu, 09 Dec 2010 14:33:47 +0100
Received: from pool-74-101-125-124.nycmny.fios.verizon.net ([74.101.125.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 14:33:47 +0100
Received: from stefanb by pool-74-101-125-124.nycmny.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 14:33:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Benvenuti <benve <at> cisco.com> writes:

> 
> The following series add the new IFLA_PORT_PROTO_* nested
> protocol attributes to rtnetlink and it updates the enic
> driver to support them.
> 
> 01/2 - Add new protocol nested IFLA_PORT_PROTO_* attrs
> 02/2 - Update enic driver to support new IFLA_PORT_PROTO_* attrs
> 
> Signed-off-by: Christian Benvenuti <benve <at> cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu <at> cisco.com>
> Signed-off-by: David Wang <dwang2 <at> cisco.com>
> 
[...]
> 
> When the protocol nested attributes IFLA_PORT_PROTO_* will be
> populated with new sub-attributes (like the CLUSTER_UUID we would like
> to add), the user space clients will have to adapt to the new
> attribute scheme if they want to be able to see/receive the new
> attributes (like CLUSTER_UUID).
> 


I don't have a problem with these changes. Just on the libvirt level it's going
to be a lot more messy. We'll need another level of #ifdef's for when these new
attributes became available. In case they are there we should not just create
the netlink messages with the new attributes but first independently probe for
802.1Qbg and 802.1Qbh for whether lldpad or the kernel respectively saw the same
level of if_link.h include and/or support the new attributes and fall back to
using the old ones in case the probing failed. That way we can support
multi-boot installations with kernels before and after these changes or an
lldpad that doesn't support the new attributes and still give the user the
experience that the starting of the VM 'works' as before (the new kernel was
installed). I am assuming that it worked with 802.1Qbh before even though you
didn't have the CLUSTER_UUID support... Now that will probably add quite a bit
to the complexity of the code and the testing. I hope you'll submit a patch like
that to libvirt mailing list.

   Stefan

> Thanks
> /Christian
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo <at> vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 




