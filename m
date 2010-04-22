From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 23:52:36 -0700 (PDT)
Message-ID: <20100421.235236.69366636.davem@davemloft.net>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
	<20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752957Ab0DVGwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:52:31 -0400
In-Reply-To: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 19 Apr 2010 12:18:07 -0700

> +	if (tb[IOV_ATTR_VF_IFNAME])
> +		vf_dev = dev_get_by_name(&init_net,
> +			nla_data(tb[IOV_ATTR_VF_IFNAME]));

It's probably best to check this for NULL and notify
the user with an error in that case (don't forget to
put 'dev' in that error path :-)

As things stand it looks like if we can't find vf_dev, we'll just send
NULL down to the vf_dev arg of the various operations and possibly
silently succeed.

That's not desirable, semantically.
