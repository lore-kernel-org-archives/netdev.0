From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: interrupt coalescing and CSUM offload
Date: Sat, 15 Sep 2012 14:09:09 +0200
Message-ID: <OFF8862166.946F925C-ONC1257A7A.00386AD8-C1257A7A.0042C1CF@transmode.se>
References: <OF3E0CDC2E.8FFEBDC0-ONC1257A79.004A2EB6-C1257A79.00502122@transmode.se> <20120914093252.020992cc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:60172 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab2IOMJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2012 08:09:13 -0400
In-Reply-To: <20120914093252.020992cc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 2012/09/14 18:32:52:
>
> On Fri, 14 Sep 2012 16:35:13 +0200
> Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
>
> >
> > I am adding interrupt coalescing to the ucc_geth driver. Unfortunately
> > there is only support for RX interrupt coalescing.
> > I wonder if there is any way "simulate" TX interrupt coalescing?
> >
> > I am also looking at adding HWCSUM support but this device can only do
> > IP header CSUM offload. This doesn't seem to be an option in Linux?
> > As I understand it, one must do CSUM offload for the whole frame, both
> > IP header and TCP/UDP csums?
> >
> >  Jocke
>
> There are a few drivers that turn off TX interrupt completely.
> They cleanup TX buffers on next send and have a timer to cleanup

Only on send? Currently ucc_geth does TX free in napi(where RX is processed too).
It would be nice if one could indicate to the drivers xmit() if there
are more frames to be sent. Then xmit() could choose not to turn on TX irq for
preceding frames.

> as well. This has performance benefits, but it does cause issues
> with local flow control (the freeing of skb is used to rate
> limit local traffic).

Was my reasoning correct w.r.t CSUM?
