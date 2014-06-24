From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning about
 sscanf usage
Date: Tue, 24 Jun 2014 15:00:25 -0700
Message-ID: <1403647225.29061.64.camel@joe-AO725>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
	 <20140624211935.20681.85586.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0070.hostedemail.com ([216.40.44.70]:60599 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752299AbaFXWAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 18:00:32 -0400
In-Reply-To: <20140624211935.20681.85586.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-24 at 16:19 -0500, Tom Lendacky wrote:
> Checkpatch issued a warning preferring to use kstrto<type> when
> using a single variable sscanf.  Change the sscanf invocation to
> a kstrtouint call.
[]
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
[]
> @@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
>  		return len;
>  
>  	workarea[len] = '\0';
> -	if (sscanf(workarea, "%x", &scan_value) == 1)
> -		*value = scan_value;
> -	else
> -		return -EIO;
> +	ret = kstrtouint(workarea, 0, value);

Don't you need to use 16 for the base here?

> +	if (ret)
> +		return ret;

Are there any issues with any of the various callers
getting a different error return?

-EINVAL/-ERANGE vs -EIO ?
