From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 3/7] vxlan: avoid checking socket multiple
 times.
Date: Wed, 9 Nov 2016 17:16:25 +0100
Message-ID: <20161109171625.1212dcb5@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-4-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751847AbcKIQQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:16:29 -0500
In-Reply-To: <1478371557-71888-4-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:53 -0700, Pravin B Shelar wrote:
> @@ -944,7 +944,9 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
>  {
>  	struct vxlan_dev *vxlan;
>  	struct vxlan_sock *sock4;
> -	struct vxlan_sock *sock6 = NULL;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct vxlan_sock *sock6;
> +#endif
>  	unsigned short family = dev->default_dst.remote_ip.sa.sa_family;
>  
>  	sock4 = rtnl_dereference(dev->vn4_sock);

This hunk seems to be unrelated to the rest of the patch (and is
certainly unrelated to the description). Please post it as a standalone
patch.

The rest of the patch looks good.

Thanks,

 Jiri
