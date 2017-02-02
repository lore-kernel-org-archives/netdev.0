From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 17/19] mlxsw: spectrum: Introduce ACL core
 with simple TCAM implementation
Date: Thu, 02 Feb 2017 17:34:48 -0500 (EST)
Message-ID: <20170202.173448.1101672639685186428.davem@davemloft.net>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
        <1486048379-19237-18-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdBBWey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 17:34:54 -0500
In-Reply-To: <1486048379-19237-18-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  2 Feb 2017 16:12:57 +0100

> +static int mlxsw_sp_acl_tcam_region_id_get(struct mlxsw_sp_acl_tcam *tcam,
> +					   u16 *p_id)
> +{
> +	u16 id;
> +
> +	id = find_first_zero_bit(tcam->used_regions, tcam->max_regions);
> +	if (id < tcam->max_regions) {
> +		set_bit(id, tcam->used_regions);
 ...
> +static void mlxsw_sp_acl_tcam_region_id_put(struct mlxsw_sp_acl_tcam *tcam,
> +					    u16 id)
> +{
> +	clear_bit(id, tcam->used_regions);
> +}
> +
> +static int mlxsw_sp_acl_tcam_group_id_get(struct mlxsw_sp_acl_tcam *tcam,
> +					  u16 *p_id)
> +{
> +	u16 id;
> +
> +	id = find_first_zero_bit(tcam->used_groups, tcam->max_groups);
> +	if (id < tcam->max_groups) {
> +		set_bit(id, tcam->used_groups);
 ...
> +static void mlxsw_sp_acl_tcam_group_id_put(struct mlxsw_sp_acl_tcam *tcam,
> +					   u16 id)
> +{
> +	clear_bit(id, tcam->used_groups);
> +}

Please use __set_bit() and __clear_bit() here since it seems very clear that
you do not require atomic operations.
