From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] bna: fix vlan tag stripping and implement its
 toggling
Date: Fri, 28 Feb 2014 17:18:18 -0500 (EST)
Message-ID: <20140228.171818.653889870218162486.davem@davemloft.net>
References: <1393593243-10334-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, jiri@resnulli.us,
	fw@strlen.de
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaB1WSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 17:18:20 -0500
In-Reply-To: <1393593243-10334-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 28 Feb 2014 14:14:03 +0100

> The recent commit "fe1624c bna: RX Filter Enhancements" disables
> VLAN tag stripping if the NIC is in promiscuous mode. This causes
> __vlan_hwaccel_put_tag() is called when the stripping is disabled.
> Because of this VLAN over bna does not work and causes BUGs in conjunction
> with openvswitch like this:
 ...
> The following patch makes the following changes so the driver:
> 1. Implements .ndo_set_features so an user can toggle VLAN tag stripping
>    on/off
> 2. Does not disable VLAN tag stripping in promiscuous mode so the driver
>    respect user's choice
> 3. Calls __vlan_hwaccel_put_tag() only when the stripping is enabled
> 
> v2:
> - make bnad_set_features static (thanks Florian Westphal)
> - enable/disable VLAN stripping during open WRT hw_features
> 
> v3:
> - enable/disable VLAN stripping during open WRT features and not hw_features
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Ok, I'm fine with this fix for now, applied thanks Ivan.
