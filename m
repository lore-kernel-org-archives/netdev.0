From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: interrupt coalescing and CSUM offload
Date: Mon, 17 Sep 2012 09:18:58 -0700
Message-ID: <20120917091858.2616d372@nehalam.linuxnetplumber.net>
References: <OF3E0CDC2E.8FFEBDC0-ONC1257A79.004A2EB6-C1257A79.00502122@transmode.se>
	<20120914093252.020992cc@nehalam.linuxnetplumber.net>
	<OFF8862166.946F925C-ONC1257A7A.00386AD8-C1257A7A.0042C1CF@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34213 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab2IQQT2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 12:19:28 -0400
In-Reply-To: <OFF8862166.946F925C-ONC1257A7A.00386AD8-C1257A7A.0042C1CF@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Sep 2012 14:09:09 +0200
Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote on 2012/09/14 18:32:52:
> >
> > On Fri, 14 Sep 2012 16:35:13 +0200
> > Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
> >
> > >
> > > I am adding interrupt coalescing to the ucc_geth driver. Unfortunately
> > > there is only support for RX interrupt coalescing.
> > > I wonder if there is any way "simulate" TX interrupt coalescing?
> > >
> > > I am also looking at adding HWCSUM support but this device can only do
> > > IP header CSUM offload. This doesn't seem to be an option in Linux?
> > > As I understand it, one must do CSUM offload for the whole frame, both
> > > IP header and TCP/UDP csums?
> > >
> > >  Jocke
> >
> > There are a few drivers that turn off TX interrupt completely.
> > They cleanup TX buffers on next send and have a timer to cleanup
> 
> Only on send? Currently ucc_geth does TX free in napi(where RX is processed too).
> It would be nice if one could indicate to the drivers xmit() if there
> are more frames to be sent. Then xmit() could choose not to turn on TX irq for
> preceding frames.
> > as well. This has performance benefits, but it does cause issues
> > with local flow control (the freeing of skb is used to rate
> > limit local traffic).
> 
> Was my reasoning correct w.r.t CSUM?
> 

I header checksum is useless to Linux. The IP header is so short that
it is already in the CPU cache and costs nothing to compute or check.
The only checksuming that matters is the data (TCP or UDP).
