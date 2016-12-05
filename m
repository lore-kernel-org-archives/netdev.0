From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] net: bridge: set error code on failure
Date: Mon, 5 Dec 2016 08:37:18 -0800
Message-ID: <20161205083718.0c0daa1a@xeon-e3>
References: <1480764803-5577-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33086 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbcLEQhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:37:23 -0500
Received: by mail-pf0-f178.google.com with SMTP id d2so64466711pfd.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 08:37:23 -0800 (PST)
In-Reply-To: <1480764803-5577-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  3 Dec 2016 19:33:23 +0800
Pan Bian <bianpan2016@163.com> wrote:

> Function br_sysfs_addbr() does not set error code when the call
> kobject_create_and_add() returns a NULL pointer. It may be better to
> return "-ENOMEM" when kobject_create_and_add() fails.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188781
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  net/bridge/br_sysfs_br.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index e120307..f88c4df 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -898,6 +898,7 @@ int br_sysfs_addbr(struct net_device *dev)
>  	if (!br->ifobj) {
>  		pr_info("%s: can't add kobject (directory) %s/%s\n",
>  			__func__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
> +		err = -ENOMEM;
>  		goto out3;
>  	}
>  	return 0;

Makes sense. Although such a small allocation should never fail.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
