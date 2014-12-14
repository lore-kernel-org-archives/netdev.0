From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Sun, 14 Dec 2014 20:23:51 +0100
Message-ID: <20141214192351.GA1850@nanopsycho.orion>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@cumulusnetworks.com, jhs@mojatatu.com,
	john.r.fastabend@intel.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:52132 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaLNTXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 14:23:53 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so6988075wiv.0
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 11:23:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 14, 2014 at 05:19:05PM CET, ogerlitz@mellanox.com wrote:
>The current implementations all use dev_uc_add_excl() and such whose API
>doesn't support vlans, so we can't make it with NICs HW for now.
>
>Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')

Maybe I'm missing something, but this commit did not introduce the
problem. If was there already before when NDA_VLAN was set and ignored.

But other than this. I like the patch

Reviewed-by: Jiri Pirko <jiri@resnulli.us>



>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
> drivers/net/ethernet/intel/i40e/i40e_main.c |    5 +++++
> net/core/rtnetlink.c                        |    5 +++++
> 2 files changed, 10 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>index 0a7ea4c..a5f2660 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>@@ -7549,6 +7549,11 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> 	if (!(pf->flags & I40E_FLAG_SRIOV_ENABLED))
> 		return -EOPNOTSUPP;
> 
>+	if (vid) {
>+		pr_info("%s: vlans aren't supported yet for dev_uc|mc_add()\n", dev->name);
>+		return -EINVAL;
>+	}
>+
> 	/* Hardware does not support aging addresses so if a
> 	 * ndm_state is given only allow permanent addresses
> 	 */
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index d06107d..9cf6fe9 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -2368,6 +2368,11 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
> 		return err;
> 	}
> 
>+	if (vid) {
>+		pr_info("%s: vlans aren't supported yet for dev_uc|mc_add()\n", dev->name);
>+		return err;
>+	}
>+
> 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
> 		err = dev_uc_add_excl(dev, addr);
> 	else if (is_multicast_ether_addr(addr))
>-- 
>1.7.1
>
