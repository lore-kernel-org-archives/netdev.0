From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/4] TCPCT part 1: initial SYN exchange with
 SYNACK data
Date: Thu, 15 Oct 2009 07:45:55 -0400
Message-ID: <4AD70B73.2040401@gmail.com>
References: <4AD6B31B.3060402@gmail.com> <20091014.231540.01186298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:59371 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762699AbZJOLqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 07:46:34 -0400
Received: by qyk2 with SMTP id 2so570677qyk.21
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 04:45:58 -0700 (PDT)
In-Reply-To: <20091014.231540.01186298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> This callback is generic and isn't designed to take opaque
> data.  All the other arguments to this callback are strongly
> typed, and this is on purpose.
> 
> You'll need to find another way to implement this.
> 
This was the most controversial change, so I made it the first separate
patch to get strong review.

#1 You recently shot down adding a GFP_ATOMIC kref (Adam's original code),
after having approved it a year ago.

#2 The entire struct could be added to all struct request_sock, but you
already rejected adding fewer bytes to the much larger tcp_sock.  And that
isn't the best strategy, as request_sock otherwise would not have a cookie
and is intended to be small.

#3 It's not possible to wrap and extend request_sock, as that is already
done by IPv6 and others, causing a conflict.  That was suggested by
another maintainer, and I drafted some code last week, but wasn't able to
figure out a non-conflicting code path.

#4 Passing a pointer parameter is the only option left that I've discovered.
Now, you've rejected that as well....

So, lead me to "another way"?
