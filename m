From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [TCP]: min_t/max_t confusion in tcp_select_initial_window()?
Date: Wed, 23 Dec 2009 21:45:57 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912232140500.10866@melkinpaasi.cs.helsinki.fi>
References: <4B3179B8.5000403@gmail.com> <20091222.194747.193724694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45305 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbZLWTp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 14:45:58 -0500
In-Reply-To: <20091222.194747.193724694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2009, David Miller wrote:

> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Wed, 23 Dec 2009 03:00:24 +0100
> 
> > I could be confused, but in net/ipv4/tcp_output.c:217:
> > 
> >                 space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
> >                 space = min_t(u32, space, *window_clamp);
> > ------------------------^^^^^
> > 
> > shouldn't the min_t and max_t be exchanged? i.e.
> > 
> >                 space = min_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
> >                 space = max_t(u32, space, *window_clamp);
> 
> It looks correct to me.
> 
> Globally, the largest window we could ever end up advertising
> is the maximum of the sysctl_tcp_rmem[2] threshold and
> sysctl_rmem_max.
> 
> But for this connection, the window clamp is our upper bound.

I don't understand how window_clamp line could be changed to max_t.
...I guess min in both would seem the most reasonable one?


-- 
 i.
