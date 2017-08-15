From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Wed, 16 Aug 2017 01:11:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1708160108050.2947@ja.home.ssi.bg>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>          <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>          <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>  <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
  <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg> <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LFD.2.20.1708160035510.2947@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47550 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752048AbdHOWL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 18:11:29 -0400
In-Reply-To: <alpine.LFD.2.20.1708160035510.2947@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 16 Aug 2017, Julian Anastasov wrote:

> 	I thought about this, it is possible in
> neigh_event_send:
> 
>         if (neigh->used != now)
>                 neigh->used = now;
> 	else if (neigh->nud_state == NUD_INCOMPLETE &&
> 		 neigh->arp_queue_len_bytes + skb->truesize >
> 		 NEIGH_VAR(neigh->parms, QUEUE_LEN_BYTES)

	With kfree_skb(skb) here, of course...

> 		return 1;
> 
> 	But this is really in fast path and not sure it is
> worth it. May be if we can move it somehow in __neigh_event_send
> but as neigh->used is changed early we need a better idea
> how to reduce the arp_queue hit rate...

Regards
