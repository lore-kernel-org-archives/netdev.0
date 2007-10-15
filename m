From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] Collect frag queues management objects together
Date: Mon, 15 Oct 2007 02:32:28 -0700 (PDT)
Message-ID: <20071015.023228.107924035.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F7145.6080707@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42248
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755499AbXJOJcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:32:24 -0400
In-Reply-To: <470F7145.6080707@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:06:13 +0400

> There are some objects that are common in all the places
> which are used to keep track of frag queues, they are:
> 
>  * hash table
>  * LRU list
>  * rw lock
>  * rnd number for hash function
>  * the number of queues
>  * the amount of memory occupied by queues
>  * secret timer
> 
> Move all this stuff into one structure (struct inet_frags)
> to make it possible use them uniformly in the future. Like
> with the previous patch this mostly consists of hunks like
> 
> -    write_lock(&ipfrag_lock);
> +    write_lock(&ip4_frags.lock);
> 
> To address the issue with exporting the number of queues and 
> the amount of memory occupied by queues outside the .c file
> they are declared in, I introduce a couple of helpers.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

'ipfrag_secret_timer' became unused, so I deleted it in this
patch too.
