From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4 net-next-2.6] ethtool: Added support for FW dump
Date: Fri, 13 May 2011 00:05:07 +0100
Message-ID: <1305241507.14174.3.camel@bwh-desktop>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305240515-29237-2-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53671 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757540Ab1ELXFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:05:10 -0400
In-Reply-To: <1305240515-29237-2-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 15:48 -0700, Anirban Chakraborty wrote:
> Added code to take FW dump via ethtool. Dump level can be controlled via setting the
> dump flag. A get function is provided to query the current setting of the dump flag.
> Dump data is obtained from the driver via a separate get function.
> 
> Changes from v3:
> Fixed buffer length issue in ethtool_get_dump_data function.
> Updated kernel doc for ethtool_dump struct and get_dump_flag function.
> 
> Changes from v2:
> Provided separate commands for get flag and data.
> Check for minimum of the two buffer length obtained via ethtool and driver and
> use that for dump buffer
> Pass up the driver return error codes up to the caller.
> Added kernel doc comments.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

There is one tiny error I didn't notice before, which I think David can
fix up if and when he applies this:

> ---
>  include/linux/ethtool.h |   31 ++++++++++++++++
>  net/core/ethtool.c      |   90 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 121 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index bd0b50b..4cbf274 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -601,6 +601,26 @@ struct ethtool_flash {
>  	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>  };
>  
> +/**
> + * struct ethtool_dump - used for retrieving, setting device dump
> + * @cmd: Command number - %ETHTOOL_GET_DUMP_FLAG, %ETHTOOL_GET_DUMP_DATA, or
> + * 	%ETHTOOL_SET_DUMP
> + * @version: FW version of the dump, filled in by driver
> + * @flag: driver dependent flag for dump setting, filled in by driver during
> + * 	  get and filled in by ethtool for set operation
> + * @len: length of dump data, used as the length of the user buffer on entry to
> + * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by driver
> + * 	 for %ETHTOOL_GET_DUMP_FLAG command
> + * @data: data collected for get dump data operation
> + */
> +struct ethtool_dump {
> +	__u32	cmd;
> +	__u32	version;
> +	__u32	flag;
> +	__u32	len;
> +	u8	data[0];

The type should be __u8 because u8 is not normally defined in userland.

Ben.

> +};
> +
>  /* for returning and changing feature sets */
>  
>  /**
[...]

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

