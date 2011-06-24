From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool_set_features suggestion
Date: Fri, 24 Jun 2011 19:40:20 +0100
Message-ID: <1308940820.3034.17.camel@bwh-desktop>
References: <4E04D576.8090902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8399 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab1FXSkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 14:40:23 -0400
In-Reply-To: <4E04D576.8090902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 11:20 -0700, Ben Greear wrote:
> static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
> {
> 	struct ethtool_sfeatures cmd;
> 	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS];
> 	netdev_features_t wanted = 0, valid = 0;
> 	int i, ret = 0;
> 
> 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> 		return -EFAULT;
> 	useraddr += sizeof(cmd);
> 
> 	if (cmd.size != ETHTOOL_DEV_FEATURE_WORDS)
> 		return -EINVAL;
> 
> (This is from net-next, with Miroslaw's patches applied)
> 
> I was thinking that we should deal with whatever size is passed in.
> That way, if we ever expand the kernel
> feature-words size, an old user-space ethtool app would
> still function OK.

Userland should find out the correct size from ETHTOOL_GFEATURES.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

