From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Fix infinite retry loop in IP-Config
Date: Wed, 28 Jan 2009 10:52:21 +0000
Message-ID: <20090128105220.GB4190@ff.dom.local>
References: <49802060.5040709@alcatel-lucent.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:62790 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbZA1K6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 05:58:30 -0500
Received: by ewy14 with SMTP id 14so2713459ewy.13
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 02:58:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49802060.5040709@alcatel-lucent.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-01-2009 10:07, Benjamin ZORES wrote:
> Hi,
> 
> The attached patch fixes some bug with ip-config max retry number.
> In ip_auto_config(), kernel tries to retrieve IP configuration forever
> in case of NFS root and some specific amount of time otherwise.
> 
> The problem is that, in case of error, the code jump to the try_try_again
> goto statement, that reassigns the retry number counter, which obviously
> leads to an infinite loop if IP config fails.
> 
> The attached patch corrects this behavior.
> Hope one can push it to mainstream kernel tree.
> 
> Ben
> 
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index 42a0f3d..4911b81 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -1268,6 +1268,7 @@ __be32 __init root_nfs_parse_addr(char *name)
>  static int __init ip_auto_config(void)
>  {
>  	__be32 addr;
> +	 int retries = CONF_OPEN_RETRIES;
 
Doesn't it need "#ifdef IPCONFIG_DYNAMIC" to prevent a compiler
warning? I guess you could add a "Signed-off-by:" line BTW.

Jarek P.
