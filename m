From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net-next] vrf: fix a kernel warning
Date: Thu, 1 Oct 2015 16:26:34 -0600
Message-ID: <560DB31A.20500@cumulusnetworks.com>
References: <1443738068-30750-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36373 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbbJAW0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 18:26:43 -0400
Received: by pablk4 with SMTP id lk4so86257819pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 15:26:42 -0700 (PDT)
In-Reply-To: <1443738068-30750-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/1/15 4:21 PM, Cong Wang wrote:
> This fixes:
>
>   tried to remove device ip6gre0 from (null)
...
>
> Fixes: 93a7e7e837af ("net: Remove the now unused vrf_ptr")
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   drivers/net/vrf.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index 64f2ab6..4743963 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -672,7 +672,7 @@ static int vrf_device_event(struct notifier_block *unused,
>   	if (event == NETDEV_UNREGISTER) {
>   		struct net_device *vrf_dev;
>
> -		if (netif_is_l3_master(dev))
> +		if (!vrf_is_slave(dev) || netif_is_l3_master(dev))
>   			goto out;
>
>   		vrf_dev = netdev_master_upper_dev_get(dev);
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>

Thanks for the fix.
