From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] bonding: add option lp_interval for loading module
Date: Fri, 20 Dec 2013 18:06:03 -0800
Message-ID: <469C6575-826C-4FF7-8FAE-78166EEB177B@cumulusnetworks.com>
References: <52B3D15F.3080703@huawei.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40968 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3LUCIO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 21:08:14 -0500
In-Reply-To: <52B3D15F.3080703@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 19, 2013, at 9:10 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:

> @@ -4271,6 +4276,12 @@ static int bond_check_params(struct bond_params *params)
> 		fail_over_mac_value = BOND_FOM_NONE;
> 	}
> 
> +	if (lp_interval == 0) {
> +		pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
> +			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
> +		lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
> +	}
> +

[sorry, replied with wrong email]

What do you think about using the new bond_option_xxx_set() functions for module parameters also?  The above code, for example, is duplicated in bond_option_lp_interval_set().  This way, we have a unified solution, where option bounds checking, compatibility, warnings, etc happened in one place for all three modes of input: sysfs, netlink, and module params.

-scott
