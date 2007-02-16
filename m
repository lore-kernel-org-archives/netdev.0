From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Fri, 16 Feb 2007 21:34:27 +0300
Message-ID: <20070216183426.GA3138@2ka.mipt.ru>
References: <20070215160405.3bd30b05@localhost.localdomain> <20070216152557.GA20641@2ka.mipt.ru> <20070216152858.GA22020@2ka.mipt.ru> <20070216153957.GB22020@2ka.mipt.ru> <20070216155450.GC22020@2ka.mipt.ru> <20070216161045.GA2371@2ka.mipt.ru> <20070216102914.7d4b34f0@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59933 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946207AbXBPSej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 13:34:39 -0500
Content-Disposition: inline
In-Reply-To: <20070216102914.7d4b34f0@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 10:29:14AM -0800, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> On Fri, 16 Feb 2007 19:10:45 +0300
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > one of the possible fixes for select() after write() after ECONNRESET.
> > 
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > 
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index b67e0dd..661ca0c 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -365,7 +365,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
> >  	 * blocking on fresh not-connected or disconnected socket. --ANK
> >  	 */
> >  	if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
> > -		mask |= POLLHUP;
> > +		mask |= POLLHUP | POLLERR;
> >  	if (sk->sk_shutdown & RCV_SHUTDOWN)
> >  		mask |= POLLIN | POLLRDNORM | POLLRDHUP;
> >  
> > 
> 
> No, that would end up setting error bit on normal shutdown. This is incorrect 
> behaviour and might even be described in SUSE standard.
> 
> There might even be LSB tests on this?

Maybe - I do not have it handy.
Otherwise we can extend select output mask to include hungup too
(getting into account that hungup is actually output event).

> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>

-- 
	Evgeniy Polyakov
