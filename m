From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] rocker: enable by default untagged VLAN
 support
Date: Mon, 01 Jun 2015 17:01:10 -0700 (PDT)
Message-ID: <20150601.170110.792713573803449471.davem@davemloft.net>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbbFBABL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:01:11 -0400
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon,  1 Jun 2015 11:39:01 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> This patch set is a followup to Simon Horman's RFC patch:
> 
>    [PATCH/RFC net-next] rocker: by default accept untagged packets
> 
> Now, on port probe, we install untagged VLAN (vid=0) support for each port
> as the default.  This is equivalent to the command:
> 
>    bridge vlan add vid 0 dev DEV self
> 
> Accepting untagged VLAN pkts is a reasonable default, but the user could
> override this with:
> 
>    bridge vlan del vid 0 dev DEV self
> 
> With this, we no longer need 8021q module to install vid=0 when port interface
> opens.  In fact, we don't need support for legacy VLAN ndo ops at all since
> they're superseded by bridge_setlink/dellink.  So remove legacy VLAN ndo ops
> support in driver.  (The legacy VLAN ndo ops are supported by bonding/team
> drivers, but don't fit into the transaction model offered by switchdev, so
> switching all VLAN functions to bridge_setlink/dellink switchdev support gets
> us stacked driver + transaction model support).

Series applied, although I do have some trepidation about patch #5 since it
removes a capability that existed beforehand so someone might (well, they will)
get confused if they try to configure vlans that way and it no longer works.

If anyone else expresses similar objections I will probably have to
revert, just FYI.
