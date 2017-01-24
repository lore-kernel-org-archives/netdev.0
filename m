From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 00/18] netvsc driver enhancements for net-next
Date: Tue, 24 Jan 2017 14:00:55 -0800
Message-ID: <20170124140055.4fac90de@xeon-e3>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
        <20170124.163005.1454633748162819090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36513 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdAXWBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:01:04 -0500
Received: by mail-pg0-f43.google.com with SMTP id t6so58138340pgt.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 14:01:04 -0800 (PST)
In-Reply-To: <20170124.163005.1454633748162819090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jan 2017 16:30:05 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 24 Jan 2017 13:05:57 -0800
> 
> > Lots of little things in here. Support for minor more ethtool control,
> > negotiation of offload parameters with host (based on FreeBSD) and
> > several cleanups.  
> 
> Series applied, but two comments for potential follow-on changes:
> 
> >   netvsc: enhance transmit select_queue  
> 
> Wouldn't it be better to check for the channel table NULL pointer
> before assigning the queue index to the socket?

Wanted to keep the original ordering out of paranoia.

> >   netvsc: call netif_receive_skb  
> 
> Hmmm, potential stack depth issues?

No more of an issue than net softirq before (ie process_backlog).
The call chain is:
  tasklet_action
	vmbus_on_event ... process_chn_event
		netvsc_channel_cb ... netif_receive_skb

NAPI/GRO support is possible but needs changes in VMBUS core code.
