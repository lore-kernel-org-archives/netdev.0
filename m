From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net] sctp: change to use TCP_CLOSE_WAIT as SCTP_SS_CLOSING
Date: Mon, 1 Aug 2016 08:41:17 -0300
Message-ID: <20160801114117.GB2954@localhost.localdomain>
References: <0517133e5f1dee8136f3a1c3bfaac522fe98e599.1469880045.git.lucien.xin@gmail.com>
 <20160730132535.GE2967@localhost.localdomain>
 <20160730.220803.1463117783142907557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199AbcHALln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 07:41:43 -0400
Content-Disposition: inline
In-Reply-To: <20160730.220803.1463117783142907557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2016 at 10:08:03PM -0700, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Sat, 30 Jul 2016 10:25:35 -0300
> 
> > On Sat, Jul 30, 2016 at 08:00:45PM +0800, Xin Long wrote:
> >> Prior to this patch, sctp defined TCP_CLOSING as SCTP_SS_CLOSING.
> >> TCP_CLOSING is such a special sk state in TCP that inet common codes
> >> even exclude it.
> >> 
> >> For instance, inet_accept thinks the accept sk's state never be
> >> TCP_CLOSING, or it will give a WARN_ON. TCP works well with that
> >> while SCTP may trigger the call trace, as CLOSING state in SCTP
> >> has different meaning from TCP.
> >> 
> >> This fix is to change to use TCP_CLOSE_WAIT as SCTP_SS_CLOSING,
> >> instead of TCP_CLOSING. Some side-effects could be expected,
> >> regardless of not being used before. inet_accept will accept it
> >> now.
> >> 
> >> I did all the func_tests in lksctp-tools and ran sctp codnomicon
> >> fuzzer tests against this patch, no regression or failure found.
> >> 
> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > 
> > I don't think this is -net material. It's a one line change but a core
> > one.
> > Dave please consider it for net-next instead.
> > Though, Xin you may need to re-post later..
> > 
> > Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> But, the commit log message says that inet_accept() will generate
> a WARN_ON() call trace without this change.  That makes it sound
> like it's 'net' material to me.
> 

That's right, it will fix a WARN_ON(). I just feel that this change is
too intrusive for -net. But if you think it's okay, okay then.

  Marcelo
