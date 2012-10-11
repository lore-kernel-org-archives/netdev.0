From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 18:15:45 +0200
Message-ID: <1349972145.21172.9685.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
	 <201210111228.25995.arnd@arndb.de>
	 <1349959248.21172.8970.camel@edumazet-glaptop> <5076C78E.1020408@gmail.com>
	 <1349963227.21172.9188.camel@edumazet-glaptop> <5076E472.8030703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34900 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758542Ab2JKQPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 12:15:49 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1096520bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 09:15:48 -0700 (PDT)
In-Reply-To: <5076E472.8030703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 10:23 -0500, Rob Herring wrote:
> On 10/11/2012 08:47 AM, Eric Dumazet wrote:

> > Compiler is asked to perform a 32bit load, it does it.
> 
> Not exactly. It is asked to to perform 2 32-bit loads which are combined
> into a single ldm (load multiple) which cannot handle unaligned
> accesses. Here's a simple example that does the same thing:


Thats simply not true. You are severely mistaken.

ldm does a load of seeral 32bit words.

And the compiler would not use it if the alignment was not matching the
prereq (alignment >= 4)



> 
> void test(char * buf)
> {
> 	printf("%d, %d\n", *((unsigned int *)&buf[0]), *((unsigned int *)&buf[4]));
> }

But you completely miss the fact that network doesnt pass a "char *buf"
but a "be32 *buf". Your example is not relevant at all.

So the compiler is absolutely right, and network stack is _right_ too.

The prereq is that IP header are aligned to 4 bytes boundary.

Denying this fact is not going to help you


> 
> So I guess the only ABI legal unaligned access is in a packed struct.
> 
> > There is no questionable optimization here. Really.
> > Please stop pretending this, this makes no sense.
> 
> I'm not the one calling the networking stack bad code.

Once you understand the issues, you can explain us where is the bad
code. But given you say "Bug is in compiler, and/or network stack, but
my driver is fine", its not very wise.

For the moment, the bug is in your driver.

> 
> I can fix my h/w, so I'll stop caring about this. Others can all get
> bitten by this new behavior in gcc 4.7.

Again compiler is fine. How should we say that so that you stop your
rants ?

Stop trying to find an excuse, dont try to fool us, this is really
embarrassing. Just fix the driver, there is no shame to fix an error.
