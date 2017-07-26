From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Wed, 26 Jul 2017 10:10:47 +0200
Message-ID: <20170726081047.562anntu5uhwirze@torres.zugschlus.de>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
 <1500905950.2458.6.camel@redhat.com>
 <20170725115745.bbguoecrcsfhbm7f@torres.zugschlus.de>
 <1500985072.13149.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:42992 "EHLO
        torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdGZIKt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 04:10:49 -0400
Content-Disposition: inline
In-Reply-To: <1500985072.13149.4.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 02:17:52PM +0200, Paolo Abeni wrote:
> On Tue, 2017-07-25 at 13:57 +0200, Marc Haber wrote:
> > On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> > > Once that a system enter the buggy status, do the packets reach the
> > > relevant socket's queue?
> > > 
> > > ss -u
> > 
> > That one only shows table headers on an unaffected system in normal
> > operation, right?
> 
> This one shows the current lenght of the socket receive queue (Recv-Q,
> the first column). If the packets land into the skbuff (and the user
> space reader for some reason is not woken up) such value will grow over
> time.

Only that there is no value:
[4/4992]mh@swivel:~ $ ss -u
Recv-Q Send-Q Local Address:Port                 Peer Address:Port              
[5/4992]mh@swivel:~ $

(is that the intended behavior on a system thiat is not affected by the
issue?)

> > > nstat |grep -e Udp -e Ip
> > > 
> > > will help checking that.
> > 
> > An unaffected system will show UdpInDatagrams, right?
> > 
> > But where is the connection to the relevant socket's queue?
> 
> If the socket queue lenght (as reported above) does not increase,
> IP/UDP stats could give an hint of where and why the packets stop
> traversing the network stack.

We'll see. Still waiting for the phenomenon to show up again.

> Beyond that, you can try using perf probes or kprobe/systemtap to [try
> to] track the relevant packets inside the kernel.

That's way beyond my kernel foo, I'm afraid.

Thanks for helping, I'll report back.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
