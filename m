From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 07:00:22 -0700
Message-ID: <1365516022.3887.131.camel@edumazet-glaptop>
References: <3505145.vfXt1x4t0P@sifl>
	 <1365469759.3887.69.camel@edumazet-glaptop>
	 <51636DEB.5000308@schaufler-ca.com> <28452040.xEi3pLPik0@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:55810 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3DIOAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 10:00:25 -0400
In-Reply-To: <28452040.xEi3pLPik0@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 09:19 -0400, Paul Moore wrote:

> As Casey already mentioned, if this isn't acceptable please help me understand 
> why.
> 

You see something which is not the reality. If you do such analysis,
better do it properly, because any change you are going to submit will
be doubly checked by people who really care.

sizeof(sk_buff) is not 280. (aligned to 320 because of cache line being
64)

Tell me what you have when doing :

ls -l /sys/kernel/slab/skbuff_head_cache

Do you really see 

$ ls -l /sys/kernel/slab/skbuff_head_cache
lrwxrwxrwx 1 root root 0 Apr  9 06:54 /sys/kernel/slab/skbuff_head_cache -> :t-0000320

Here I get :

$ ls -l /sys/kernel/slab/skbuff_head_cache
lrwxrwxrwx 1 root root 0 Apr  9 06:54 /sys/kernel/slab/skbuff_head_cache -> :t-0000256

because sizeof(sk_buff) <= 256
