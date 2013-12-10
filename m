From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] vxlan: remove vxlan_group_used in vxlan_open
Date: Mon, 09 Dec 2013 19:32:44 -0500 (EST)
Message-ID: <20131209.193244.2227545675987687506.davem@davemloft.net>
References: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab3LJAcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 19:32:46 -0500
In-Reply-To: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 5 Dec 2013 17:01:35 +0800

> In vxlan_open, vxlan_group_used always returns true,
> because the state of the vxlan deivces which we want
> to open has alreay been running. and it has already
> in vxlan_list.
> 
> Since ip_mc_join_group takes care of the reference
> problem. we can remove vxlan_group_used here, let
> ip_mc_join_group resolve the reference problem.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

"already" is misspelled in this commit message.

Please describe what "the reference problem" actually is.

> @@ -1943,8 +1943,7 @@ static int vxlan_open(struct net_device *dev)
>  	if (!vs)
>  		return -ENOTCONN;
>  
> -	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
> -	    vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
> +	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {

This makes "vn" unused, please remove it.

The compiler even warns about this, are you watching the build
after making changes for messages like that?
