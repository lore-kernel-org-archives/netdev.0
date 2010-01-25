From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp_probe: avoid modulus operation and wrap fix
Date: Mon, 25 Jan 2010 08:30:06 -0800
Message-ID: <20100125083006.47fd2f7e@nehalam>
References: <20100124215001.78251e25@nehalam>
	<20100124.224122.13742906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33892 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab0AYQai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 11:30:38 -0500
In-Reply-To: <20100124.224122.13742906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Jan 2010 22:41:22 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sun, 24 Jan 2010 21:50:01 -0800
> 
> > @@ -75,12 +75,12 @@ static struct {
> >  
> >  static inline int tcp_probe_used(void)
> >  {
> > -	return (tcp_probe.head - tcp_probe.tail) % bufsize;
> > +	return (tcp_probe.head - tcp_probe.tail) & (bufsize - 1);
> >  }
> >  
> >  static inline int tcp_probe_avail(void)
> >  {
> > -	return bufsize - tcp_probe_used();
> > +	return bufsize - tcp_probe_used() - 1;
> >  }
> >  
> >  /*
> 
> Hmmm...  When the ring is full head==tail, which means
> tcp_probe_used() returns 0.  Which would now make tcp_probe_avail()
> return "bufsize - 0 - 1".
> 
> Is that right?

Yes. in this ring; empty is head == tail, and full needs to
be tail == head - 1.

-- 
