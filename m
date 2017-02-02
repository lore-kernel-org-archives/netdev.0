From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 19/19] mlxsw: spectrum: Implement TC flower
 offload
Date: Thu, 2 Feb 2017 13:37:23 -0800
Message-ID: <2bf7a90d-6ec4-8265-bb29-7797e262e570@gmail.com>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <1486048379-19237-20-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32822 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBBVhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 16:37:25 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so59961pgd.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 13:37:25 -0800 (PST)
In-Reply-To: <1486048379-19237-20-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 07:12 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Extend the existing setup_tc ndo call and allow to offload cls_flower
> rules. Only limited set of dissector keys and actions are supported now.
> Use previously introduced ACL infrastructure to offload cls_flower rules
> to be processed in the HW.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> ---

> +	tcf_exts_to_list(exts, &actions);
> +	list_for_each_entry(a, &actions, list) {
> +		if (is_tcf_gact_shot(a)) {
> +			err = mlxsw_sp_acl_rulei_act_drop(rulei);
> +			if (err)
> +				return err;
> +		} else if (is_tcf_mirred_egress_redirect(a)) {
> +			int ifindex = tcf_mirred_ifindex(a);
> +			struct net_device *out_dev;
> +
> +			out_dev = __dev_get_by_index(dev_net(dev), ifindex);
> +			if (out_dev == dev)
> +				out_dev = NULL;

You are not checking here that out_dev has the same netdev_ops pointer
(unlike the matchall case), is that expected?
-- 
Florian
