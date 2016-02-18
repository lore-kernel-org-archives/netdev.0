From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] cxgb3: fix up vpd strings for kstrto*()
Date: Thu, 18 Feb 2016 16:04:39 +0300
Message-ID: <56C5C167.7080205@cogentembedded.com>
References: <20160217233126.E0815E0753@smtp.ogc.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, davem@davemloft.net, hariprasad@chelsio.com
To: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32831 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945948AbcBRNEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:04:42 -0500
Received: by mail-lf0-f47.google.com with SMTP id m1so32232921lfg.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 05:04:41 -0800 (PST)
In-Reply-To: <20160217233126.E0815E0753@smtp.ogc.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/17/2016 11:36 PM, Steve Wise wrote:

> The vpd strings are left justified, in a fixed length array, with possible
> trailing white space and no NUL.  So fix them up before calling kstrto*().
>
> This is a recent regression which causes cxgb3 to fail to load.
>
> Fixes:e72c932('cxgb3: Convert simple_strtoul to kstrtox')
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb3/t3_hw.c | 32 +++++++++++++++++++++++-------
>   1 file changed, 25 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
> index ee04caa..bfd4a7f 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
> @@ -681,6 +681,24 @@ int t3_seeprom_wp(struct adapter *adapter, int enable)
>   	return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 0xc : 0);
>   }
>
> +static int vpdstrtouint(char *s, int len, unsigned int base, unsigned int *val)
> +{
> +	char tok[len+1];

    The Linus coding style generally requires the operators to be surrounded 
by spaces.

> +
> +	memcpy(tok, s, len);
> +	tok[len] = 0;
> +	return kstrtouint(strim(tok), base, val);
> +}
> +
> +static int vpdstrtou16(char *s, int len, unsigned int base, u16 *val)
> +{
> +	char tok[len+1];

    Likewise.

> +
> +	memcpy(tok, s, len);
> +	tok[len] = 0;
> +	return kstrtou16(strim(tok), base, val);
> +}
> +
>   /**
>    *	get_vpd_params - read VPD parameters from VPD EEPROM
>    *	@adapter: adapter to read
[...]

MBR, Sergei
