From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC VLAN 10/10]: Use rtnl_link API
Date: Tue, 05 Jun 2007 14:31:59 -0700
Message-ID: <4665D64F.4040601@candelatech.com>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain> <20070605143703.23717.96479.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33695 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932084AbXFEVcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 17:32:05 -0400
In-Reply-To: <20070605143703.23717.96479.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> [VLAN]: Use rtnl_link API
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

> +static int vlan_newlink(struct net_device *dev,
> +			struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
> +	int err;
> +
> +	if (!tb[IFLA_LINK])
> +		return -EINVAL;
> +	if (!data[IFLA_VLAN_ID])
> +		return -EINVAL;
> +
> +	vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
> +	vlan->real_dev = __dev_get_by_index(nla_get_u32(tb[IFLA_LINK]));

It seems you are scribbling on dev->priv before you validate that
it is OK to do so?

Or, maybe I'm just confused.

What is 'dev' here?

> +
> +	if (!vlan->real_dev)
> +		return -ENODEV;
> +	err = vlan_check_real_dev(vlan->real_dev, vlan->vlan_id);
> +	if (err < 0)
> +		return err;
> +
> +	err = vlan_changelink(dev, tb, data);
> +	if (err < 0)
> +		return err;
> +
> +	return register_vlan_dev(dev);
> +}


Other than this, this patch and the others in this series
look fine (except for the 4095 VID issue that we communicated
about earlier).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

