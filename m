From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [REGRESSION v3.14-rc2] NULL dereference in icmp6_send()
Date: Mon, 17 Feb 2014 19:50:53 +0100
Message-ID: <20140217185053.GF22833@order.stressinduktion.org>
References: <nsxzjlp4lxm.fsf@closure.thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <nsxzjlp4lxm.fsf@closure.thunk.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

On Mon, Feb 17, 2014 at 01:46:13PM -0500, Theodore Ts'o wrote:
> I was sitting in the Admiral's Club of Boston Logan airport, having
> connected to the free airport wifi, although I had not yet logged into
> the captive portal, when I received the following BUG.   I've also seen
> this once before when connected to my home network (running the CeroWRT
> stable snapshot, versoin 3.7.5-2), although I wasn't able to get a
> screen shot that time:
> 
> https://plus.google.com/photos/+TheodoreTso/albums/5981437894092747105/5981437896646076466
> 
> The transcribed stack dump is:
> 
> icmp6_send
> ip6_expire_frag_queue
> ip6_frag_expire
> call_timer_fn
> run_timer_softirq
> irq_exit
> ...
> 
> I was running v3.13 and v3.13-rcX previously without seeing this, so I
> suspect this is a regression.

At that point the skb does not have a dst attached, so we panic in
icmp6_send.

This is fixed here:
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=d94c1f92bbf2c42c5febd68bbea51fffeac90834

Greetings,

  Hannes
