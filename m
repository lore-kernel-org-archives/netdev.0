From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 17/19] mlxsw: spectrum: Introduce ACL core with
 simple TCAM implementation
Date: Fri, 3 Feb 2017 07:53:44 +0100
Message-ID: <20170203065344.GA1871@nanopsycho.orion>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <1486048379-19237-18-git-send-email-jiri@resnulli.us>
 <20170202.173448.1101672639685186428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33101 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752272AbdBCGxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 01:53:47 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so2250522wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 22:53:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170202.173448.1101672639685186428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 02, 2017 at 11:34:48PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu,  2 Feb 2017 16:12:57 +0100
>
>> +static int mlxsw_sp_acl_tcam_region_id_get(struct mlxsw_sp_acl_tcam *tcam,
>> +					   u16 *p_id)
>> +{
>> +	u16 id;
>> +
>> +	id = find_first_zero_bit(tcam->used_regions, tcam->max_regions);
>> +	if (id < tcam->max_regions) {
>> +		set_bit(id, tcam->used_regions);
> ...
>> +static void mlxsw_sp_acl_tcam_region_id_put(struct mlxsw_sp_acl_tcam *tcam,
>> +					    u16 id)
>> +{
>> +	clear_bit(id, tcam->used_regions);
>> +}
>> +
>> +static int mlxsw_sp_acl_tcam_group_id_get(struct mlxsw_sp_acl_tcam *tcam,
>> +					  u16 *p_id)
>> +{
>> +	u16 id;
>> +
>> +	id = find_first_zero_bit(tcam->used_groups, tcam->max_groups);
>> +	if (id < tcam->max_groups) {
>> +		set_bit(id, tcam->used_groups);
> ...
>> +static void mlxsw_sp_acl_tcam_group_id_put(struct mlxsw_sp_acl_tcam *tcam,
>> +					   u16 id)
>> +{
>> +	clear_bit(id, tcam->used_groups);
>> +}
>
>Please use __set_bit() and __clear_bit() here since it seems very clear that
>you do not require atomic operations.

Will do.
