From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Sat, 27 Mar 2004 02:03:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403270203.18971.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403270014.23088.vda@port.imtp.ilyichevsk.odessa.ua> <20040326233514.B26347@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andreas Henriksson <andreas@fjortis.info>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040326233514.B26347@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 27 March 2004 00:35, Francois Romieu wrote:
> Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
> [...]
>
> > Yes. But on x86 a++ is atomic vs interrupts - it's a single instruction
> > and interrupts happen on instruction boundaries only.
>
> Do you realize that you are saying that the CPU can atomically increment an
> integer which sits _in memory_ ?

Not exactly. CPU does not atomically increment memory.
I am saying that x86 CPU can't be interrupted in the middle
of read-modify-write operation, like

		incl	(%eax)

because it is single machine instruction. Interrupt either
happens before it, and handler see 'old' value, or after it,
and handler see 'new' value. Interrupt cannot happen 'inside' it.

Some RISC processors lack such single-instruction RMW ops.
Bug can thrigger on those CPUs:
		load	(%r1),r2
		inc	v2	
			<-------- interrupt here. Ouch!
		store	v2,(%r1)
Not on x86.
--
vda
