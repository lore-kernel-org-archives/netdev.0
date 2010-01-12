From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Tue, 12 Jan 2010 12:11:33 -0500
Message-ID: <4B4CAD45.5080606@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4C4962.8040207@gmail.com> <4B4C52EA.6070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:32584 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab0ALRLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 12:11:37 -0500
In-Reply-To: <4B4C52EA.6070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Seems fine, but :
> 
> 1) What means the "Transformed ?" you wrote several times ?
> 
The only reason that I've been able to figure out for having the
skb->len test in those places is the preceding xfrm4_policy_check()
or xfrm6_policy_check() must be able to shrink the skb->len?

When I did the original transform stuff in other code circa 1995, I'd
envisioned IP length or link layer (PPP) length shrinking (removing
padding after block ciphers) -- and apparently this implementation
extended that concept to transport layer, too.

Personally, I'd prefer that a single test be placed in the appropriate
spot in the xfrm* functions, instead.  Anybody know where?
