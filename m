From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/sctp: stack-out-of-bounds in sctp_getsockopt
Date: Wed, 23 Mar 2016 10:14:50 -0700
Message-ID: <1458753290.10868.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56f16034.890c620a.e04dc.ffffc770@mx.google.com>
	 <1458660088.10868.19.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1458660478.10868.21.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAP=GMUFA-qAOxF1W=aeWDYBiR-GSohJYGHiMDsrqwsD0xdg3_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Baozeng <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35555 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbcCWROx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:14:53 -0400
In-Reply-To: <CAP=GMUFA-qAOxF1W=aeWDYBiR-GSohJYGHiMDsrqwsD0xdg3_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 00:42 +0800, Baozeng wrote:

> Thanks for your quick patch. I tested it but it still reproduce the
> bug. We should limit the length of the name,
> not the prefix. The following patch fixs it.
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 67b2e27..4837425 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -346,7 +346,7 @@ find_inlist_lock(struct list_head *head, const
> char *name, const char *prefix,
>  {
>         return try_then_request_module(
>                         find_inlist_lock_noload(head, name, error, mutex),
> -                       "%s%s", prefix, name);
> +                       "%s%.*s", prefix, EBT_TABLE_MAXNAMELEN, name);
> }
> 

Right you are, please send a formal patch ?

Thanks !
