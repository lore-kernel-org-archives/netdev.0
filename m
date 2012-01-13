From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 09:45:26 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF41@saturn3.aculab.com>
References: <1326437318.2617.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Alexey Dobriyan" <adobriyan@gmail.com>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	<ken@codelabs.ch>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Steffen Klassert" <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1326437318.2617.17.camel@edumazet-laptop>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Good catch. It can be generalized to any interrupts (soft and hard)
> 
> Another solution is using two blocks, one used from interrupt context.
> 
> static DEFINE_PER_CPU(u64[80], msg_schedule);
> static DEFINE_PER_CPU(u64[80], msg_schedule_irq);
> 
> (Like we do for SNMP mibs on !x86 arches)

Don't you need one block per interrupt level ?

It also means that the functions need to know where they
are being called from - which may not be true.

A thought is that if you are going to reserve this memory
for each cpu, it might as well be reserved as part of the
interrupt stack (assuming interrupts switch stacks).

Process level code would still need to use a reserved buffer.

	David
