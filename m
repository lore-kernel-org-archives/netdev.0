From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: fix setlink/dellink notifications
Date: Sat, 17 Jan 2015 23:50:29 -0500 (EST)
Message-ID: <20150117.235029.1501863173667971316.davem@davemloft.net>
References: <1421294545-52467-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	john.fastabend@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	sfeldma@gmail.com, jiri@resnulli.us, wkok@cumulusnetworks.com,
	ronen.arad@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbAREuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 23:50:55 -0500
In-Reply-To: <1421294545-52467-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Wed, 14 Jan 2015 20:02:25 -0800

> problems with bridge getlink/setlink notifications today:
>         - bridge setlink generates two notifications to userspace
>                 - one from the bridge driver
>                 - one from rtnetlink.c (rtnl_bridge_notify)
>         - dellink generates one notification from rtnetlink.c. Which
> 	means bridge setlink and dellink notifications are not
> 	consistent
> 
>         - Looking at the code it appears,
> 	If both BRIDGE_FLAGS_MASTER and BRIDGE_FLAGS_SELF were set,
>         the size calculation in rtnl_bridge_notify can be wrong.
>         Example: if you set both BRIDGE_FLAGS_MASTER and BRIDGE_FLAGS_SELF
>         in a setlink request to rocker dev, rtnl_bridge_notify will
> 	allocate skb for one set of bridge attributes, but,
> 	both the bridge driver and rocker dev will try to add
> 	attributes resulting in twice the number of attributes
> 	being added to the skb.  (rocker dev calls ndo_dflt_bridge_getlink)
> 
> There are multiple options:
> 1) Generate one notification including all attributes from master and self:
>    But, I don't think it will work, because both master and self may use
>    the same attributes/policy. Cannot pack the same set of attributes in a
>    single notification from both master and slave (duplicate attributes).
> 
> 2) Generate one notification from master and the other notification from
>    self (This seems to be ideal):
>      For master: the master driver will send notification (bridge in this
> 	example)
>      For self: the self driver will send notification (rocker in the above
> 	example. It can use helpers from rtnetlink.c to do so. Like the
> 	ndo_dflt_bridge_getlink api).
> 
> This patch implements 2) (leaving the 'rtnl_bridge_notify' around to be used
> with 'self').
...
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
