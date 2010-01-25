From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_probe: avoid modulus operation and wrap fix
Date: Mon, 25 Jan 2010 15:48:14 -0800 (PST)
Message-ID: <20100125.154814.56026460.davem@davemloft.net>
References: <20100124215001.78251e25@nehalam>
	<20100124.224122.13742906.davem@davemloft.net>
	<20100125083006.47fd2f7e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33571
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214Ab0AYXsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 18:48:02 -0500
In-Reply-To: <20100125083006.47fd2f7e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 25 Jan 2010 08:30:06 -0800

> On Sun, 24 Jan 2010 22:41:22 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Sun, 24 Jan 2010 21:50:01 -0800
>> 
>> > @@ -75,12 +75,12 @@ static struct {
>> >  
>> >  static inline int tcp_probe_used(void)
>> >  {
>> > -	return (tcp_probe.head - tcp_probe.tail) % bufsize;
>> > +	return (tcp_probe.head - tcp_probe.tail) & (bufsize - 1);
>> >  }
>> >  
>> >  static inline int tcp_probe_avail(void)
>> >  {
>> > -	return bufsize - tcp_probe_used();
>> > +	return bufsize - tcp_probe_used() - 1;
>> >  }
>> >  
>> >  /*
>> 
>> Hmmm...  When the ring is full head==tail, which means
>> tcp_probe_used() returns 0.  Which would now make tcp_probe_avail()
>> return "bufsize - 0 - 1".
>> 
>> Is that right?
> 
> Yes. in this ring; empty is head == tail, and full needs to
> be tail == head - 1.

Ok, that makes sense, thanks for explaining.

Applied, thanks Stephen.
