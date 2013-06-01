From: Joe Perches <joe@perches.com>
Subject: Re: [Patch net-next] icmp: avoid allocating large struct on stack
Date: Fri, 31 May 2013 20:34:29 -0700
Message-ID: <1370057669.10556.104.camel@joe-AO722>
References: <1370057053-20519-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47978 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755270Ab3FADea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 23:34:30 -0400
In-Reply-To: <1370057053-20519-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-01 at 11:24 +0800, Cong Wang wrote:
> struct icmp_bxm is a large struct, reduce stack usage
> by allocating it on heap.
[]
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
[]
> @@ -558,6 +558,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>  		}
>  	}
>  
> +	icmp_param = kzalloc(sizeof(*icmp_param), GFP_ATOMIC);

why kzalloc if the previous stack was uninitialized?
