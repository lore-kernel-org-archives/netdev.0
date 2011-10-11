From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] netconsole: enable netconsole can make net_device refcnt
Date: Tue, 11 Oct 2011 16:05:48 +0800
Message-ID: <4E93F8DC.5080909@cn.fujitsu.com>
References: <4E93E238.7000105@cn.fujitsu.com> <1318319438-7159-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53371 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752810Ab1JKIFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 04:05:19 -0400
In-Reply-To: <1318319438-7159-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Im so sorry.
the first patch has some format err.
Please use this one.
thanks wanlong! ^V^

11.10.2011 15:50, Wanlong Gao wrote:
> There is no check if netconsole is enabled current.
> so when exec echo 1 > enabled;
> the reference of net_device will increment always.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  drivers/net/netconsole.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index ed2a397..4e6323df 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -307,6 +307,8 @@ static ssize_t store_enabled(struct netconsole_target *nt,
>  		return err;
>  	if (enabled < 0 || enabled > 1)
>  		return -EINVAL;
> +	if (enabled == nt->enabled)
> +		return err;
>  
>  	if (enabled) {	/* 1 */
>  
