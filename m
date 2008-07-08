From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 08:54:43 +0400
Message-ID: <20080708045443.GA7726@2ka.mipt.ru>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, shemminger@vyatta.com, netdev@vger.kernel.org,
	rees@umich.edu, bfields@fieldses.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:57656 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbYGHEzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 00:55:16 -0400
Content-Disposition: inline
In-Reply-To: <20080707.144912.76654646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Mon, Jul 07, 2008 at 02:49:12PM -0700, David Miller (davem@davemloft.net) wrote:
> There is no reason these days to ever explicitly set the socket
> buffer sizes on TCP sockets under Linux.
> 
> If something is going wrong it's a bug and we should fix it.

Just for the reference: autosizing is (was?) not always working correctly
for some workloads at least couple of years ago.
For example I worked with small enough embedded systems with 16-32 MB
of RAM where socket buffer size never grew up more than 200Kb (100mbit
network), but workload was very bursty, so if remote system froze for
several milliseconds (and sometimes upto couple of seconds), socket
buffer was completely filled with new burst of data and either sending
started to sleep or returned EAGAIN, which resulted in semi-realtime
data to be dropped.

Setting buffer size explicitely to large enough value like 8Mb fixed
this burst issues. Another fix was to allocate data each time it becomes
ready and copy portion to this buffer, but allocation was quite slow,
which led to unneded latencies, which again could lead to data loss.

-- 
	Evgeniy Polyakov
