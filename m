From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] nfnetlink: do not ack malformed messages
Date: Fri, 08 Nov 2013 02:03:20 +0300
Message-ID: <527C1C38.40908@cogentembedded.com>
References: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Petr Matousek <pmatouse@redhat.com>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:36135 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799Ab3KGWDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 17:03:30 -0500
Received: by mail-la0-f53.google.com with SMTP id eh20so985830lab.12
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 14:03:29 -0800 (PST)
In-Reply-To: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/07/2013 09:59 PM, Jiri Benc wrote:

> Commit 0628b123c96d ("netfilter: nfnetlink: add batch support and use it
> from nf_tables") introduced a bug leading to various crashes in netlink_ack
> when netlink message with invalid nlmsg_len was sent by an unprivileged
> user.

> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>   net/netfilter/nfnetlink.c |    8 +++++---
>   1 files changed, 5 insertions(+), 3 deletions(-)

> diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
> index 027f16a..046aa13 100644
> --- a/net/netfilter/nfnetlink.c
> +++ b/net/netfilter/nfnetlink.c
> @@ -363,13 +363,15 @@ static void nfnetlink_rcv(struct sk_buff *skb)
>   	struct net *net = sock_net(skb->sk);
>   	int msglen;
>
> -	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> -		return netlink_ack(skb, nlh, -EPERM);
> -

    Hm, how it even compiled before your patch?

WBR, Sergei
