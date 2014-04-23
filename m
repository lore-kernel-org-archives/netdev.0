From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: skb_try_coalesce bug?
Date: Wed, 23 Apr 2014 12:56:20 -0400
Message-ID: <5357F0B4.5040606@ericsson.com>
References: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>	 <1398172293.29946.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <5356C518.7050602@ericsson.com>	 <1398197116.29946.60.camel@edumazet-glaptop2.roam.corp.google.com>	 <5356D2AF.7030401@ericsson.com>	 <1398202178.29946.62.camel@edumazet-glaptop2.roam.corp.google.com> <1398202653.29946.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:45578 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbaDWQ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:56:32 -0400
In-Reply-To: <1398202653.29946.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2014 05:37 PM, Eric Dumazet wrote:
> On Tue, 2014-04-22 at 14:29 -0700, Eric Dumazet wrote:
> 
>> Then if you do that, you also need to change head->data_len !
> 
> Untested patch would be :
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index c5190ab75290..85077dd7c63e 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -2349,6 +2349,7 @@ int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
>  			(*tail)->next = frag;
>  		*tail = frag;
>  		(*head)->truesize += frag->truesize;
> +		(*head)->data_len += frag->len;

Just to confirm, does this mean that head's own (linear) data is not
included in data_len? 

///jon

>  	}
>  	if (fragid == LAST_FRAGMENT) {
>  		*fbuf = *head;
> 
> 
