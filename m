From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Sat, 29 Jun 2013 19:58:00 +0400
Message-ID: <51CF0408.5020607@cogentembedded.com>
References: <1372479115-7003-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:53195 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab3F2P57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 11:57:59 -0400
Received: by mail-la0-f45.google.com with SMTP id fr10so3115035lab.4
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 08:57:57 -0700 (PDT)
In-Reply-To: <1372479115-7003-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-06-2013 8:11, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> This is a regression introduced by
> commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)

> Similar to GRE tunnel, previously we only check the parameters
> for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
> check is moved for all commands.

> So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.

> Also, the check for i_key, o_key etc. is suspicious too,
> which did not exist before.

> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

> ---
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index e6905fb..9d6ca81 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -244,11 +244,11 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
>   		return -EFAULT;
>
> -	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
> -			p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
> -		return -EINVAL;
> -	if (p.i_key || p.o_key || p.i_flags || p.o_flags)
> -		return -EINVAL;
> +	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
> +		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
> +		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))

    Maybe it's time to put spaces around & to make code formatting more 
consistent here too?

WBR, Sergei
