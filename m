From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RT] net: move xmit_recursion to per-task variable on -RT
Date: Thu, 14 Jan 2016 14:20:04 -0800
Message-ID: <1452810004.1223.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160113152352.GH29964@linutronix.de>
	 <alpine.DEB.2.11.1601131830440.3575@nanos>
	 <20160114145007.GC17776@linutronix.de> <56981AE1.20202@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34911 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbcANWUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 17:20:06 -0500
In-Reply-To: <56981AE1.20202@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-14 at 23:02 +0100, Hannes Frederic Sowa wrote:

> We are just adding a second recursion limit solely to openvswitch which 
> has the same problem:
> 
> https://patchwork.ozlabs.org/patch/566769/
> 
> This time also we depend on rcu_read_lock marking the section being 
> nonpreemptible. Nice would be a more generic solution here which doesn't 
> need to always add something to *current.


Note that rcu_read_lock() does not imply that preemption is disabled.
