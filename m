From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 06/18] netlabel: Add support for creating a CALIPSO protocol domain mapping.
Date: Sun, 07 Feb 2016 14:56:01 -0500
Message-ID: <1869616.Jjv9uvE9Ou@sifl>
References: <1452246774-13241-7-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbcBGT4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 14:56:06 -0500
In-Reply-To: <1452246774-13241-7-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 08, 2016 09:52:42 AM Huw Davies wrote:
> This extends the NLBL_MGMT_C_ADD and NLBL_MGMT_C_ADDDEF commands
> to accept CALIPSO protocol DOIs.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>

...

> @@ -300,6 +311,11 @@ static int netlbl_domhsh_validate(const struct
> netlbl_dom_map *entry) entry->def.cipso == NULL)
>  			return -EINVAL;
>  		break;

In netlbl_domhsh_validate() you should also check to ensure that entry-
>def.calipso is NULL in the NETLBL_NLTYPE_UNLABELED case similar to what we do 
for CIPSO.

> @@ -233,6 +252,9 @@ static int netlbl_mgmt_add_common(struct genl_info
> *info, map->list.valid = 1;
>  		map->def.type = entry->def.type;
> 
> +		if (calipso)
> +			map->def.calipso = calipso;
> +

This is another nit-picky comment, and I'll only mention it this one time, but 
there are a number of places in this patchset where I think you are adding 
undesirable vertical whitespace.  In the if-block above, the whitespace above 
the "if (calipso)" line is inconsistent with other similar parts of the 
function (e.g. the CIPSO based code) and doesn't make the code any easier to 
read.

I mention this not because such things are grounds for NACK'ing a patch, but 
just something to make note of and fix if you happen to be updating the 
patch(set) anyway.

>  		ret_val = netlbl_af6list_add(&map->list, &addrmap->list6);
>  		if (ret_val != 0) {
>  			kfree(map);

-- 
paul moore
security @ redhat
