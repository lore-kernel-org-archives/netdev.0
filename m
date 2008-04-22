From: David Miller <davem@davemloft.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
 version of Tomasz's patch set
Date: Tue, 22 Apr 2008 15:42:12 -0700 (PDT)
Message-ID: <20080422.154212.108914213.davem@davemloft.net>
References: <20080421131253.GB12221@ghostprotocols.net>
	<200804211817.01189.tomasz@grobelny.oswiecenia.net>
	<20080422174152.GD6039@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasz@grobelny.oswiecenia.net, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753167AbYDVWmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 18:42:10 -0400
In-Reply-To: <20080422174152.GD6039@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Apr 2008 18:41:52 +0100

> | If we iron this out we could finally return to the main subject of this 
> | thread. That is Patch v2 by me and Gerrit...
> | -- 
> Fully agree - we just need to decide whether or not to use skb->priority.
> 
> Below is as far as I got in integrating your patch last week, it shows
> only the major changes. The following bits have been updated:
> 
>  * skb->priority now cleared before passing the skb onto layer 3;
>  * order of statements in prio_push() reversed (first dropping worst
>    skb and then pushing the new skb - this is better when e.g.
>    tx_qlen=1);
>  * added general parsing routine for cmsg(3) socket control messages
>    and defined one for the SOL_DCCP socket level; thanks to advice
>    by Dave Miller

If this usage of skb->priority is going to override the
IP_TOS socket option setting, I don't think it's a good
idea.

Right now every packet output goes through ip_output.c
which sets skb->priority to sk->sk_priority, which is set
by the user via the IP_TOS socket option in ip_sockglue.c
