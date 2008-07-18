From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 21:53:41 +0400
Message-ID: <20080718175341.GA21496@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807181850.07393.opurdila@ixiacom.com> <20080718160009.GA29740@2ka.mipt.ru> <200807182004.44664.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:35620 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbYGRRxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 13:53:49 -0400
Content-Disposition: inline
In-Reply-To: <200807182004.44664.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Jul 18, 2008 at 08:04:44PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> Suppose we have 20 packets in the socket queue and the pipe is empty and the 
> application calls splice(sock, pipe, 17, flags=0).
> 
> Then, tcp_splice_read will be called, which in turn calls tcp_read_sock. 
> 
> tcp_read_sock will loop until all the 17 bytes will be read from the socket. 
> tcp_read_sock calls skb_splice_bits which calls splice_to_pipe.

How come?
spd_fill_page() should fail when it will be called for the 17'th skb and
all reading from the socket will return, and thus can be sent to the
file.

> Now while skb_splice_bits is carefull to only put a maximum of PIPE_BUFFERS 
> during its iteration, due to the looping in tcp_read_sock, we will end up 
> with 17 calls to splice_to_pipe. Thus on the 17th call, splice_to_pipe will 
> block.

Where exactly?
Why 
tcp_splice_data_recv()->skb_splice_bits()->__skb_splice_bits()->spd_fill_page()
callchain does not return error and that pipe is full?

-- 
	Evgeniy Polyakov
