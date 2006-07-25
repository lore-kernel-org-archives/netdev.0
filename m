From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv4/IPv6] Setting 0 for unused port field. (fwd)
Date: Tue, 25 Jul 2006 23:53:40 +0900 (JST)
Message-ID: <20060725.235340.99246287.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.64.0607251045470.21222@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:14867 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932378AbWGYOwQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 10:52:16 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607251045470.21222@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.64.0607251045470.21222@d.namei> (at Tue, 25 Jul 2006 10:45:51 -0400 (EDT)), James Morris <jmorris@namei.org> says:

> The recvmsg() for raw socket seems to return random u16 value
> from the kernel stack memory since port field is not initialized.
> But I'm not sure this patch is correct.
> Does raw socket return any information stored in port field?
> 
> ---------- Start of patch ----------
> diff -ur before/net/ipv4/raw.c after/net/ipv4/raw.c
> --- before/net/ipv4/raw.c       2006-06-18 10:49:35.000000000 +0900
> +++ after/net/ipv4/raw.c        2006-07-25 16:15:26.000000000 +0900
> @@ -609,6 +609,7 @@
>         if (sin) {
>                 sin->sin_family = AF_INET;
>                 sin->sin_addr.s_addr = skb->nh.iph->saddr;
> +               sin->sin_port = 0;
>                 memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
>         }
>         if (inet->cmsg_flags)

Well, instead, should it be initalized to protocol number, shouldn't it?

--yoshfuji
