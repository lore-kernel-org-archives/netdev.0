From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Tue, 25 Jul 2017 14:17:52 +0200
Message-ID: <1500985072.13149.4.camel@redhat.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
         <1500905950.2458.6.camel@redhat.com>
         <20170725115745.bbguoecrcsfhbm7f@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751776AbdGYMRz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 08:17:55 -0400
In-Reply-To: <20170725115745.bbguoecrcsfhbm7f@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-07-25 at 13:57 +0200, Marc Haber wrote:
> On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> > Once that a system enter the buggy status, do the packets reach the
> > relevant socket's queue?
> > 
> > ss -u
> 
> That one only shows table headers on an unaffected system in normal
> operation, right?

This one shows the current lenght of the socket receive queue (Recv-Q,
the first column). If the packets land into the skbuff (and the user
space reader for some reason is not woken up) such value will grow over
time.

> > nstat |grep -e Udp -e Ip
> > 
> > will help checking that.
> 
> An unaffected system will show UdpInDatagrams, right?
> 
> But where is the connection to the relevant socket's queue?

If the socket queue lenght (as reported above) does not increase,
IP/UDP stats could give an hint of where and why the packets stop
traversing the network stack.

Beyond that, you can try using perf probes or kprobe/systemtap to [try
to] track the relevant packets inside the kernel.

/P
