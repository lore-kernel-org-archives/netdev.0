From: David Miller <davem@davemloft.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 12:40:02 -0500 (EST)
Message-ID: <20120119.124002.1964667767933832927.davem@davemloft.net>
References: <201201191207.10207.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: hans.schillstrom@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932569Ab2ASRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 12:40:10 -0500
In-Reply-To: <201201191207.10207.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Thu, 19 Jan 2012 12:07:09 +0100

> Closing of a namespace (container) can be delayed by ~ 2 minutes 
> due to tcp timers ex tcp time wait (and of cource other things too).
> 
> I think there should be some kind of "forced close" of the Network stack
> in ex free_nsproxy() 

I think this is unwise.

Keeping the timewait sockets around is necessary to absorb any lingering
packets in the network meant for those sockets.

If you truncate this activity, and then try to create another socket with
the same ID you'll run into the very problems time-wait is meant to
solve.

It's an unfortunate delay, but one you will have to live with.
