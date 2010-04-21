From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 23:22:36 +0200
Message-ID: <201004212322.36671.arnd@arndb.de>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com> <201004201548.26609.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:57164 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256Ab0DUVW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 17:22:57 -0400
In-Reply-To: <201004201548.26609.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 April 2010, Arnd Bergmann wrote:
> > + * @IOV_ATTR_IFNAME: interface name of master (PF) net device (NLA_NUL_STRING)
> > + * @IOV_ATTR_VF_IFNAME: interface name of target VF device (NLA_NUL_STRING)
> 
> As mentioned above, why not drop one of these, and just pass the VF's IFNAME?
> 

Coming back to this point, I now think it would be ideal if we could actually
leave out IOV_ATTR_VF_IFNAME and just pass the master IFNAME and the slave
MAC address. Since we're not actually doing anything with the slave itself
but really talking the switch, it should not be needed at all.

That would solve all problems with the slave having moved to another namespace
already, and make it totally clear that this is not about configuring the
slave but about registering it.

Scott, would that still work with your driver?

	Arnd
