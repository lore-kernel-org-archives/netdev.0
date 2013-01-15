From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/5] soreuseport: UDP/IPv4 implementation
Date: Tue, 15 Jan 2013 07:58:03 -0800
Message-ID: <20130115075803.17ed2bc5@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1301141140320.3523@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:51119 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab3AOP7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 10:59:32 -0500
Received: by mail-pb0-f47.google.com with SMTP id wz17so118127pbc.34
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 07:59:31 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1301141140320.3523@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2013 12:00:23 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 79c8dbe..1dd1e93 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -139,6 +139,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
>  {
>  	struct sock *sk2;
>  	struct hlist_nulls_node *node;
> +	int uid = sock_i_uid(sk);
>  

I am not a namespace expert, but it looks like this might have
to use from_kuid_munged(). At a minimum it should be:
         kuid_t uid = sock_i_uid(sk);
