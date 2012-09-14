From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: interrupt coalescing and CSUM offload
Date: Fri, 14 Sep 2012 09:32:52 -0700
Message-ID: <20120914093252.020992cc@nehalam.linuxnetplumber.net>
References: <OF3E0CDC2E.8FFEBDC0-ONC1257A79.004A2EB6-C1257A79.00502122@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54870 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab2INQdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 12:33:24 -0400
In-Reply-To: <OF3E0CDC2E.8FFEBDC0-ONC1257A79.004A2EB6-C1257A79.00502122@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Sep 2012 16:35:13 +0200
Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:

> 
> I am adding interrupt coalescing to the ucc_geth driver. Unfortunately
> there is only support for RX interrupt coalescing.
> I wonder if there is any way "simulate" TX interrupt coalescing?
> 
> I am also looking at adding HWCSUM support but this device can only do
> IP header CSUM offload. This doesn't seem to be an option in Linux?
> As I understand it, one must do CSUM offload for the whole frame, both
> IP header and TCP/UDP csums?
> 
>  Jocke

There are a few drivers that turn off TX interrupt completely.
They cleanup TX buffers on next send and have a timer to cleanup
as well. This has performance benefits, but it does cause issues
with local flow control (the freeing of skb is used to rate
limit local traffic).
