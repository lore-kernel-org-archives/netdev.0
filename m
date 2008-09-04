From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 07/38] netns ct: add ->ct_net -- pointer from conntrack
 to netns
Date: Thu, 04 Sep 2008 18:18:22 +0200
Message-ID: <48C00A4E.5060103@trash.net>
References: <20080821215934.GG31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32808 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbYIDQSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 12:18:24 -0400
In-Reply-To: <20080821215934.GG31136@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adobriyan@gmail.com wrote:
> Conntrack (struct nf_conn) gets pointer to netns: ->ct_net -- netns in which
> it was created. It comes from netdevice.
> 
> ->ct_net is write-once field.
> 
> Every conntrack in system has ->ct_net initialized, no exceptions.
> 
> ->ct_net doesn't pin netns: conntracks are recycled after timeouts and
> pinning background traffic will prevent netns from even starting shutdown
> sequence.
> 
> Right now every conntrack is created in init_net.

Applied and fixed up another overly long line.

> +		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);

This will probably cause clashes later, please don't
do that.
