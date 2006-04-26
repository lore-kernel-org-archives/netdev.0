From: Jens Axboe <axboe@suse.de>
Subject: BUG: e1000 Invalid truesize
Date: Wed, 26 Apr 2006 16:25:23 +0200
Message-ID: <20060426142523.GA5002@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.virtualhost.dk ([195.184.98.160]:4692 "EHLO virtualhost.dk")
	by vger.kernel.org with ESMTP id S964792AbWDZOYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 10:24:43 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

My problematic e1000 card (that sporadically gets transmit timeouts with
a driver newer than 2.6.14) hits new problems in current git after this
commit:

    [NET]: Add skb->truesize assertion checking.

I thought I'd mention it, since it may help fix the real problem.
Basically I get tons of:

SKB BUG: Invalid truesize (592) len=712, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=448, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=712, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=448, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (592) len=500, sizeof(sk_buff)=208
[...]

and some net connections don't work well. Putting the 2.6.14 driver back
into current git makes things work smoothly, as always.

(Please be sure to cc me, I'm not on netdev)

-- 
Jens Axboe

