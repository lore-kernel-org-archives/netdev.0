From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses (with [PATCH])
Date: Wed, 31 Mar 2004 22:38:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403312238.46835.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403311839.33202.vda@port.imtp.ilyichevsk.odessa.ua> <20040331192421.GA30048@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Francois Romieu <romieu@fr.zoreil.com>,
        Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>
In-Reply-To: <20040331192421.GA30048@scream.fjortis.info>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you for testing!

On Wednesday 31 March 2004 21:24, Andreas Henriksson wrote:
> On Wed, Mar 31, 2004 at 06:39:33PM +0200, Denis Vlasenko wrote:
> > Ok, here is what I have now.
> >
> > What we had before:
> > original behaviour: Andreas had tx tomeouts, I had fatal oops.
>
> I had tx-related kernel panic with vanilla driver on my p-166.
>
> > francois+jgarzik patch: Andreas happy, I had lockup (endless 'Too much
> > work')
>
> with spin_lock_irqsave in start_tx I haven't been able to trigger the
> panic on my p3-600 .. (Although, I don't know if it actually fixed the
> problem or if it's just harder to trigger on a faster machine.. but I've
> been moving ALOT of data so even if it's 10 or 100 times hard I should
> have triggered it by now..)
>
> so jgarzik's patch is enough to make me happy... no more panic but I
> still see this which is annoying when trying to do interactive stuff
> over the network:
>
> -- snip --
> NETDEV WATCHDOG: eth1: transmit timed out
> eth1: Transmit timed out, status 00000000, resetting...
> NETDEV WATCHDOG: eth1: transmit timed out
> eth1: Transmit timed out, status 00000000, resetting...
> NETDEV WATCHDOG: eth1: transmit timed out
> eth1: Transmit timed out, status 00000000, resetting...

Is it happens several times in a row? I see the same thing,
actually, when my netcat madly spews UDPs, it happens
endlessly, until I kill netcat.

So, maybe I can cure this too by replacing tx timeout code
with code which I use for 'too much work' codepath.

> > I modified 'Too much work in interrupt' code.
> > I added code which completely stops rx and tx and schedules
> > card reset a-la reset previously used in tx_timeout code path.
> > There is 1 second delay.
>
> To me it doesn't seem better nor worse then before... so I guess if it
> helps you in any way, good.

Yes, you do not trigger this. Your box use original code
still living in tx timeout path.
--
vda
