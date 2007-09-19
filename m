From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT events get missed for TCP sockets
Date: Wed, 19 Sep 2007 15:55:58 -0700 (PDT)
Message-ID: <640879.56443.qm@web53701.mail.re2.yahoo.com>
References: <20070919.154402.34760338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidel@xmailserver.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53701.mail.re2.yahoo.com ([206.190.37.22]:46702 "HELO
	web53701.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751675AbXISWz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:55:59 -0400
In-Reply-To: <20070919.154402.34760338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- David Miller <davem@davemloft.net> wrote:

> From: Nagendra Tomar <tomer_iisc@yahoo.com>
> Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)
> 
> > With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait call will 
> > not return, even when the incoming acks free the buffers.
> >         Note that this patch assumes that the SOCK_NOSPACE check in
> > tcp_check_space is a trivial optimization which can be safely removed.
> 
> I already replied to your patch posting explaining that whatever is
> not setting SOCK_NOSPACE should be fixed instead.
> 
> Please address that, thanks.

Dave, 
     I agree that setting SOCK_NOSPACE would have been a more elegant
fix. Infact I thought a lot about that before deciding on this fix.
    But the point here is that the SOCK_NOSPACE bit can be set when 
the sndbuf space is really less (less than sk_stream_min_wspace())
and some user action (sendmsg or poll) indicated his intent to write.
    In the case mentioned none of these is true. Since user wants
to manage his tranmit buffers himself, his definition of less may
not match with what kernel feels is less. f.e. user might have 
dynamically changing mmap'ed buffer resources at his disposal 
which he wants to use as sendfile buffers. He wants to be notified
whenever a new incoming ack frees up one or more of his buffers,
so that he can reuse that buffer.
    The bigger problem is that user is not indicating his intent
to write, to the kernel. He is just watching the sendbuf space and
when it matches his needs he will send new data. 

Thanx,
Tomar

 



      ___________________________________________________________ 
Want ideas for reducing your carbon footprint? Visit Yahoo! For Good  http://uk.promotions.yahoo.com/forgood/environment.html
