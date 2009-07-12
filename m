From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Avoid transmitting during sky2_restart()
Date: Sun, 12 Jul 2009 10:18:17 -0700
Message-ID: <20090712101817.5399f06d@nehalam>
References: <392fb48f0907112239j4c85932cj3f5f180bb8507143@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56109 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753912AbZGLRSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 13:18:38 -0400
In-Reply-To: <392fb48f0907112239j4c85932cj3f5f180bb8507143@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Jul 2009 14:39:29 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Hi Stephen,
> 
> "ifconfig eth1 up; pktget eth1" will crashed my machine within 10
> seconds. (eth1 is sky2)
> It appears that sky2_tx_timeout causes a restart, and packets in the
> tx queue are free'd twice (once in sky2_status_intr and once in
> sky2_down).
> Furthermore, if sky2_xmit_frame is called during sky2_restart, bad
> things will happen.
> 
> This patch fixes both problems and was tested on top of my previous
> sky2_down fix.
> 
> thanks,
> 
> Mike

This should be fixed by managing the queue properly, not
by using a state flag. I will correct the problem.
