From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 19/19] mlxsw: spectrum: Implement TC flower
 offload
Date: Fri, 3 Feb 2017 08:38:12 +0100
Message-ID: <20170203073812.GE1871@nanopsycho.orion>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <1486048379-19237-20-git-send-email-jiri@resnulli.us>
 <2bf7a90d-6ec4-8265-bb29-7797e262e570@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, jbenc@redhat.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33147 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdBCHiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 02:38:15 -0500
Received: by mail-wm0-f67.google.com with SMTP id v77so2490457wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 23:38:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2bf7a90d-6ec4-8265-bb29-7797e262e570@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 02, 2017 at 10:37:23PM CET, f.fainelli@gmail.com wrote:
>On 02/02/2017 07:12 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Extend the existing setup_tc ndo call and allow to offload cls_flower
>> rules. Only limited set of dissector keys and actions are supported now.
>> Use previously introduced ACL infrastructure to offload cls_flower rules
>> to be processed in the HW.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> ---
>
>> +	tcf_exts_to_list(exts, &actions);
>> +	list_for_each_entry(a, &actions, list) {
>> +		if (is_tcf_gact_shot(a)) {
>> +			err = mlxsw_sp_acl_rulei_act_drop(rulei);
>> +			if (err)
>> +				return err;
>> +		} else if (is_tcf_mirred_egress_redirect(a)) {
>> +			int ifindex = tcf_mirred_ifindex(a);
>> +			struct net_device *out_dev;
>> +
>> +			out_dev = __dev_get_by_index(dev_net(dev), ifindex);
>> +			if (out_dev == dev)
>> +				out_dev = NULL;
>
>You are not checking here that out_dev has the same netdev_ops pointer
>(unlike the matchall case), is that expected?

This is done later on in mlxsw_sp_acl_rulei_act_fwd.
