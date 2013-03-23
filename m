From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ip_gre: increase inner ip header ID only for
 IPv4
Date: Sat, 23 Mar 2013 19:10:46 +0400
Message-ID: <514DC5F6.9060904@cogentembedded.com>
References: <1364016584-7189-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:44516 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab3CWPLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 11:11:49 -0400
Received: by mail-la0-f47.google.com with SMTP id fj20so8932874lab.20
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 08:11:47 -0700 (PDT)
In-Reply-To: <1364016584-7189-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-03-2013 9:29, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> Pravin pointed out the inner network header of a GRE tunnel packet
> could be IPv6, where there is no ID. So we should check the version.

> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

> ---
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index e20631c..a2516f5 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
[...]
> @@ -172,7 +172,12 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>   	skb->mac_len = skb_inner_network_offset(skb);
>
>   	iph = ip_hdr(skb);
> -	id = ntohs(iph->id);
> +	if (iph->version == 4) {
> +		ipv4 = true;
> +		id = ntohs(iph->id);
> +	} else
> +		ipv4 = false;

    Both arms of *if* statement should have {}, according to 
Documentation/CodingStyle chapter 3.

WBR, Sergei
