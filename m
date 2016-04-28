From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] vxlan: fix ethernet address initialization
Date: Thu, 28 Apr 2016 12:28:19 +0200
Message-ID: <20160428122819.032da3fb@griffin>
References: <1461837856-4316-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbcD1K2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 06:28:24 -0400
In-Reply-To: <1461837856-4316-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Apr 2016 12:04:16 +0200, Nicolas Dichtel wrote:
> Since commit 0c867c9bf84c, when the user specifies an ethernet address with
> IFLA_ADDRESS, it's overridden by vxlan_ether_setup() (rtnl_link_ops->setup
> is called in rtnetlink.c before handling IFLA_ADDRESS).
> 
> To test it:
> ip link add name vxlan1 address de:ad:de:4c:0f:c2 type vxlan id 1 group 239.0.0.10 dev eth0

Good catch, Nicholas. I wrote a lnst recipe to test tons of
combinations of vxlan settings but did not think about including also
link parameters :-(

This affects not only IFLA_ADDRESS but also IFLA_MTU, IFLA_BROADCAST
and IFLA_TXQLEN. I'll try to solve all of these.

Thanks for catching this.

 Jiri
