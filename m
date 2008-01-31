From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 20:03:26 +0100
Message-ID: <20080131190326.GF4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <47A212CB.1060403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60879 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763053AbYAaS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:28:59 -0500
Content-Disposition: inline
In-Reply-To: <47A212CB.1060403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 10:26:19AM -0800, Rick Jones wrote:
> Andi Kleen wrote:
> >TSO interacts badly with many queueing disciplines because they rely on 
> >reordering packets from different streams and the large TSO packets can 
> >make this difficult. This patch disables TSO for sockets that send over 
> >devices with non standard queueing disciplines. That's anything but noop 
> >or pfifo_fast and pfifo right now.
> 
> Does this also imply that JumboFrames interacts badly with these qdiscs? 
>  Or IPoIB with its 65000ish byte MTU?

Correct. Of course it is always relative to the link speed. So if your
link is 10x faster and your packets 10x bigger you can get similarly
smooth shaping.

-Andi
