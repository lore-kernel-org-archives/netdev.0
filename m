From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Fri, 22 Mar 2013 18:37:30 +0400
Message-ID: <514C6CAA.2090902@cogentembedded.com>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Meng, Jilin" <Jilin.Meng@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:61728 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab3CVOil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:38:41 -0400
Received: by mail-la0-f49.google.com with SMTP id fs13so7433612lab.36
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 07:38:40 -0700 (PDT)
In-Reply-To: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-03-2013 7:20, Meng, Jilin wrote:

> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address
> while the switch side isn't configured bonding/channel yet.

> Signed-off-by: Jilin Meng <jilin.meng@emc.com>
> Signed-off-by: Yinglin Sun <yinglin.sun@emc.com>
> Signed-off-by: Lakshmanan Prithviraj <lakshmanan.prithviraj@emc.com>
> ---
> --- linux/net/ipv6/ndisc.c.orig	2013-03-12 17:16:18.000000000 +0800
> +++ linux/net/ipv6/ndisc.c	2013-03-21 10:37:06.000000000 +0800
> @@ -757,6 +757,24 @@ static void ndisc_recv_ns(struct sk_buff
>
>   		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>   			if (dad) {
> +				if (dev->type == ARPHRD_ETHER) {
> +					const unsigned char *sadr;

    Empty line after declaration wouldn't hurt.

> +					sadr = skb_mac_header(skb);
> +					if (sadr[6] == dev->dev_addr[0] &&
> +					    sadr[7] == dev->dev_addr[1] &&
> +					    sadr[8] == dev->dev_addr[2] &&
> +					    sadr[9] == dev->dev_addr[3] &&
> +					    sadr[10] == dev->dev_addr[4] &&
> +					    sadr[11] == dev->dev_addr[5]) {

    Don't we have memcmp() in Linux?

WBR, Sergei
