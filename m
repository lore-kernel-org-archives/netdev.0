From: Amir Vadai <amirv@mellanox.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 6 Aug 2013 15:15:05 +0300
Message-ID: <5200E8C9.5070808@mellanox.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <eliezer.tamir@linux.intel.com>, <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:49483 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756083Ab3HFMQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:16:26 -0400
In-Reply-To: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2013 00:22, Shawn Bohrer wrote:
> I did a little testing of the new low latency/busy poll sockets today
> and found a few things that surprised me and at least one bug.
> 
> 1) I'm testing with a Mellanox ConnectX-3 card.  
Of course :)

> Currently polling
> with mlx4_en is broken when GRO is enabled.  In
> mlx4_en_process_rx_cq() when GRO is enabled skb_mark_napi_id() is
> never called.  It appears like low latency sockets with GRO is
> supposed to work because the following code checks that we are not
> ll_polling:
> 
>  /* This packet is eligible for GRO if it is:
>    * - DIX Ethernet (type interpretation)
>    * - TCP/IP (v4)
>    * - without IP options
>    * - not an IP fragment
>    * - no LLS polling in progress
>    */
>   if (!mlx4_en_cq_ll_polling(cq) &&
>       (dev->features & NETIF_F_GRO)) {
> 
> However since we never call skb_mark_napi_id() mlx4_en_cq_ll_polling()
> will never be true.

Currently GRO and LLS are mutually exclusive, and shouldn't be used
together.
I will send a fix to make the code clearer soon.

Thanks for reporting,
Amir
