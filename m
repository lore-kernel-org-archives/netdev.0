From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Tue, 25 May 2010 22:08:58 -0700
Message-ID: <20100525220858.1071f238@nehalam>
References: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ycheng@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358Ab0EZFJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 01:09:01 -0400
In-Reply-To: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 May 2010 22:01:13 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> This patch allows an application to set the TCP congestion window
> for a connection through a socket option.  The maximum value that
> may set is specified in a sysctl value.  When the sysctl is set to
> zero, the default value, the socket option is disabled.
> 
> The socket option is most useful to set the initial congestion
> window for a connection to a larger value than the default in
> order to improve latency.  This socket option would typically be
> used by an "intelligent" application which might have better knowledge
> than the kernel as to what an appropriate initial congestion window is.
> 
> One use of this might be with an application which maintains per
> client path characteristics.  This could allow setting the congestion
> window more precisely than which could be achieved through the
> route command.
> 
> A second use of this might be to reduce the number of simultaneous
> connections that a client might open to the server; for instance
> when a web browser opens multiple connections to a server.  With multiple
> connections the aggregate congestion window is larger than that of a
> single connecton (num_conns * cwnd), this effectively can be used to
> circumvent slowstart and improve latency.  With this socket option, a
> single connection with a large initial congestion window could be used,
> which retains the latency properties of multiple connections but
> nicely reducing # of connections (load) on the network.
> 
> The systctl to enable and control this feature is
> 
>   net.ipv4.tcp_user_cwnd_max
> 
> The socket option call would be:
> 
>   setsockopt(fd, IPPROTO_TCP, TCP_CWND, &val, sizeof (val))
> 
> where val is the congestion window in # MSS.
> 

The IETF TCP maintainers already think Linux TCP allows unsafe
operation, this will just allow more possible misuse and prove
their argument.  Until/unless this behavior was approved by
a wider set of research, I don't think it should be accepted at
this time.


-- 
