From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 04:40:53 -0700 (PDT)
Message-ID: <20090421.044053.155783771.davem@davemloft.net>
References: <200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
	<20090421.035731.200252490.davem@davemloft.net>
	<200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 21 Apr 2009 20:39:08 +0900

> David Miller wrote:
>> There is no sane way for the user to handle this connection
>> being aborted, and there is no way to insert the connection
>> back into the listening socket queue once we get to this
>> point so we can't replay this situation either.
>> 
> Excuse me, I couldn't catch.
> 
> I don't have a problem that there is no way to insert the connection back into
> the listening socket queue once we get to this point. I want to drop the
> connection rather than pushing the connection back to the queue.

I am saying that you shouldn't be dropping connections like
this.

You've already accepted the packet, you cannot reneg on this.
You must either allow the socket to have the connection with
current labels or give it a label appropriate for the socket.
