From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 01:58:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.015815.91322249.davem@redhat.com>
References: <20030520074848.U40843@shell.cyberus.ca>
	<20030520.173607.88482742.davem@redhat.com>
	<20030522084003.GA22613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030522084003.GA22613@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Thu, 22 May 2003 01:40:03 -0700

     9631 handle_IRQ_event                          60.1938

Are you using APIC irqs?

    26552 fn_hash_lookup                            92.1944
   
   Hmm!  I guess the routing table size has a slight difference on
   performance there.

I assume you have CONFIG_IP_ROUTE_LARGE_TABLES enabled.

If not, try with that turned on.   If you had it on or enabling
it makes little difference, it is time to play with FZ_MAX_DIVISOR
and fn_hash().

All of your BGP routes have the same prefix right?  Yes, with ~181000
routes which you have fib zone hash in current state will fall to
pieces I am afraid.  (even with perfect hash, chain length would be
on the order of ~180 entries :-((( )

   I'm not sure if this is a "good" profile or not... I can try with
   oprofile or something instead if that gives more useful results.
   
It is good, thanks.

Alexey, I will try to make something...
