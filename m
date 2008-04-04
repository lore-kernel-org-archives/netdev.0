From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Date: Fri, 4 Apr 2008 10:26:44 -0300
Message-ID: <20080404132644.GA5989@ghostprotocols.net>
References: <47F61B5C.8090105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755962AbYDDN0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 09:26:49 -0400
Content-Disposition: inline
In-Reply-To: <47F61B5C.8090105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Apr 04, 2008 at 02:13:16PM +0200, Patrick McHardy escreveu:

> commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Apr 4 14:10:23 2008 +0200
> 
>     [DCCP]: Fix skb->cb conflicts with IP
>     
>     dev_queue_xmit() and the other IP output functions expect to get a skb
>     with clear or properly initialized skb->cb. Unlike TCP and UDP, the
>     dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
>     so the DCCP-specific data is interpreted by the IP output functions.
>     This can cause false negatives for the conditional POST_ROUTING hook
>     invocation, making the packet bypass the hook.
>     
>     Add a inet_skb_parm/inet6_skb_parm union to the beginning of
>     dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
>     sure it fits in the cb.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Thanks Patrick,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
