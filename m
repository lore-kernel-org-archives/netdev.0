From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next v2] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 19:52:44 +0400
Message-ID: <51CF02CC.7070907@cogentembedded.com>
References: <1372471480-28992-1-git-send-email-amwang@redhat.com> <1372472672-1900-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:61503 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3F2Pwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 11:52:44 -0400
Received: by mail-lb0-f175.google.com with SMTP id r10so1547968lbi.20
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 08:52:42 -0700 (PDT)
In-Reply-To: <1372472672-1900-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 29-06-2013 6:24, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> When testing GRE tunnel, I got:

>   # ip tunnel show
>   get tunnel gre0 failed: Invalid argument
>   get tunnel gre1 failed: Invalid argument

> This is a regression introduced by commit c54419321455631079c7d
> ("GRE: Refactor GRE tunneling code.") because previously we
> only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> after that commit, the check is moved for all commands.

> So, just move it back inside SIOCADDTUNNEL and SIOCCHGTUNNEL.

> After this patch I got:

>   # ip tunnel show
>   gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
>   gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit

> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v2: check TUNNEL_* flags

[...]
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 394cebc..dc7d7ac 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -712,6 +712,11 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
>
>   	case SIOCADDTUNNEL:
>   	case SIOCCHGTUNNEL:
> +		if (p->iph.version != 4 || p->iph.protocol != IPPROTO_GRE ||
> +		    p->iph.ihl != 5 || (p->iph.frag_off&htons(~IP_DF)) ||
> +		    ((p->i_flags|p->o_flags)&(TUNNEL_VERSION|TUNNEL_ROUTING)))

    Maybe it's time to insert spaces around & to make the code formatted 
consistently?

WBR, Sergei
