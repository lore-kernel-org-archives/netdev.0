From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 2/2] ip_tunnel: Add fallback tunnels to the hash lists
Date: Wed, 25 Sep 2013 09:03:11 -0700
Message-ID: <CALnjE+rrm3Vzov4sUjBfEKHwzRb6MfTRhkA_B96yuNGpgFgiCg@mail.gmail.com>
References: <20130925055418.GV7660@secunet.com>
	<20130925055519.GW7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:55113 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754575Ab3IYQDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 12:03:13 -0400
Received: by mail-qa0-f46.google.com with SMTP id j7so3542728qaq.19
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 09:03:11 -0700 (PDT)
In-Reply-To: <20130925055519.GW7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 10:55 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Currently we can not update the tunnel parameters of
> the fallback tunnels because we don't find them in the
> hash lists. Fix this by adding them on initialization.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/ip_tunnel.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index b8ce640..f2348f2 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -853,8 +853,10 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
>         /* FB netdevice is special: we have one, and only one per netns.
>          * Allowing to move it to another netns is clearly unsafe.
>          */
> -       if (!IS_ERR(itn->fb_tunnel_dev))
> +       if (!IS_ERR(itn->fb_tunnel_dev)) {
>                 itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
> +               ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
> +       }
>         rtnl_unlock();
>
fallback tunnel s not required to be in hash table, Its is returned if
none of hashed tunnels are matched, ref ip_tunnel_lookup().
Can you post command to reproduce this issue?

>         return PTR_RET(itn->fb_tunnel_dev);
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
