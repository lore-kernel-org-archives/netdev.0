From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 13:57:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626035824.D68B62C147@lists.samba.org>
References: <20030625.143334.85380461.davem@redhat.com>
Cc: paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Wed, 25 Jun 2003 14:33:34 MST."
             <20030625.143334.85380461.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030625.143334.85380461.davem@redhat.com> you write:
> 
> Why don't you just queue the payload packets in a "resolution queue"
> until the socket is created?  Just make the resolution queue packets
> timeout using a value that will easily exceed any reasonable PPP
> negotiation time.

Sure, that works in this case, where you know when you get the packet
that it's out of order.  But I wanted to see how ugly it got to do it
generally: a protocol where you can't tell until later that things
were in the wrong order can't use this technique.  Paul tells me that
multilink PPP assumes this (moral: don't do multilink PPPoE).

Anyway, my patch is fundamentally flawed: you can't do
cpu_raise_softirq() on another CPU, it's racy (*bad* *bad* interface).

> All this ordered packet arrival shit is just beyond stupid.

I want to know how often this is happening (Michal?), because if
protocols need ordering and can't tell, it becomes effectively a
packet drop somewhere down in the protocol.  If it's 1 in a million,
OK.  If it's 1 in a thousand, that's bad.

Frankly, I'm amazed anyone sees reordering in real life...
Thanks,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
