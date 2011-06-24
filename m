From: Ben Greear <greearb@candelatech.com>
Subject: ethtool_set_features suggestion
Date: Fri, 24 Jun 2011 11:20:38 -0700
Message-ID: <4E04D576.8090902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39883 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab1FXSUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 14:20:42 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5OIKcxH011749
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 11:20:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
{
	struct ethtool_sfeatures cmd;
	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS];
	netdev_features_t wanted = 0, valid = 0;
	int i, ret = 0;

	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
		return -EFAULT;
	useraddr += sizeof(cmd);

	if (cmd.size != ETHTOOL_DEV_FEATURE_WORDS)
		return -EINVAL;

(This is from net-next, with Miroslaw's patches applied)

I was thinking that we should deal with whatever size is passed in.
That way, if we ever expand the kernel
feature-words size, an old user-space ethtool app would
still function OK.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

