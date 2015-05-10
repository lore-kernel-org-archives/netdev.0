From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Sun, 10 May 2015 21:50:18 +0200
Message-ID: <20150510195018.GA7877@salvia>
References: <1431277170-4618-3-git-send-email-pablo@netfilter.org>
 <554F9946.9040707@plumgrid.com>
 <20150510175934.GA3799@salvia>
 <554F9DE8.3000507@plumgrid.com>
 <20150510182414.GA4198@salvia>
 <554FA7A5.5020400@plumgrid.com>
 <20150510190039.GA4938@salvia>
 <554FAC3A.40701@plumgrid.com>
 <20150510192044.GA7173@salvia>
 <554FB366.7080509@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53337 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbbEJTpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 15:45:34 -0400
Content-Disposition: inline
In-Reply-To: <554FB366.7080509@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 12:37:10PM -0700, Alexei Starovoitov wrote:
> On 5/10/15 12:20 PM, Pablo Neira Ayuso wrote:
[...]
> Another non-technical 'guess' ?
> 
> baseline with Daniel's two patches:
>    text	   data	    bss	    dec	    hex	filename
> 10605509	1885208	1400832	13891549	 d3f7dd	vmlinux
> 
> then with:
> -static inline struct sk_buff *handle_ing(struct sk_buff *skb,
> +static noinline struct sk_buff *handle_ing(struct sk_buff *skb,
> 
>    text	   data	    bss	    dec	    hex	filename
> 10605572	1885208	1400832	13891612	 d3f81c	vmlinux
> 
> so not inlining handle_ing() actually may have an impact on everyone,
> because .text gets bigger. Though only marginally.
> 
> btw, after removing 'inline' keyword gcc still inlines it automatically
> and looking at the above numbers gcc is doing the right call.

Please, stop this.

The numbers show that the existing approach and your approach results
in less performance for everyone that don't need to filter from
ingress. We have to move ingress to where it belongs.
