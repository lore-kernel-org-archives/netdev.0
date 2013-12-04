From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Wed, 04 Dec 2013 13:46:40 +0100
Message-ID: <529F2430.9050906@6wind.com>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Hangbin Liu <liuhangbin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55631 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab3LDMqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 07:46:43 -0500
Received: by mail-wi0-f178.google.com with SMTP id ca18so8087605wib.11
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 04:46:42 -0800 (PST)
In-Reply-To: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hangbin,

vti interfaces precisely need an o_key to be configured (it must be set
to the mark of ipsec policies attached to this interface). Consequently,
this flag must not be removed.

Best Regards,
Christophe

On 12/04/2013 09:48 AM, Hangbin Liu wrote:
> vti tunnel use IPPROTO_IPIP instead of IPPROTO_GRE, and keys are not allowed
> with ipip tunnel. So there is no reason to set GRE_KEY flag for vti.
>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>   net/ipv4/ip_vti.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 52b802a..58c4e6a 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -185,10 +185,8 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   	if (err)
>   		return err;
>
> -	if (cmd != SIOCDELTUNNEL) {
> -		p.i_flags |= GRE_KEY | VTI_ISVTI;
> -		p.o_flags |= GRE_KEY;
> -	}
> +	if (cmd != SIOCDELTUNNEL)
> +		p.i_flags |= VTI_ISVTI;
>
>   	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
>   		return -EFAULT;
>
