From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/8] net: dsa: cleanup resources upon module
 removal
Date: Tue, 13 Jan 2015 16:31:22 +0300
Message-ID: <54B51E2A.1040006@cogentembedded.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com> <1421099866-3184-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, buytenh@wantstofly.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:59296 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbbAMNb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 08:31:26 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so2526423lbv.12
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 05:31:24 -0800 (PST)
In-Reply-To: <1421099866-3184-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/13/2015 12:57 AM, Florian Fainelli wrote:

> We were not doing anything while removing the dsa module, which means
> that we were leaving dangling network devices without any sort of driver
> backing them, leading to all sorts of crashes. Make sure that we do
> cleanup the slave network devices, slave MII bus we created, and
> unassign the master_netdev dsa_ptr to make the packet processing go
> through the regulard Ethernet receive path.

    Regular. :-)

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index de77c83cfd9a..df7ec066ac64 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -316,10 +316,22 @@ out:
>
>   static void dsa_switch_destroy(struct dsa_switch *ds)
>   {
> +	int i;

    Need empty line here.

>   #ifdef CONFIG_NET_DSA_HWMON
>   	if (ds->hwmon_dev)
>   		hwmon_device_unregister(ds->hwmon_dev);
>   #endif

[...]

WBR, Sergei
