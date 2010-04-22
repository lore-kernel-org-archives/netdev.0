From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 12:53:11 +0200
Message-ID: <201004221253.11290.arnd@arndb.de>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com> <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com> <20100421.235236.69366636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, netdev@vger.kernel.org, chrisw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:53973 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916Ab0DVKxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 06:53:35 -0400
In-Reply-To: <20100421.235236.69366636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 April 2010, David Miller wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> Date: Mon, 19 Apr 2010 12:18:07 -0700
> 
> > +     if (tb[IOV_ATTR_VF_IFNAME])
> > +             vf_dev = dev_get_by_name(&init_net,
> > +                     nla_data(tb[IOV_ATTR_VF_IFNAME]));
> 
> It's probably best to check this for NULL and notify
> the user with an error in that case (don't forget to
> put 'dev' in that error path :-)

Since you brought up that hunk: shouldn't the namespace better
be current->nsproxy->net_ns instead of init_ns? If the sender
is confined in a separate network namespace, I would expect
that it should be able to modify devices in its own namespace
but none that are in the root namespace.

	Arnd
